import UIKit

final class ImagesListViewController: UIViewController, CoordinatedByFeedProtocol {
    
    weak var coordinator: FeedCoordinatorProtocol?
    private var photos: [Photo] = []
    private var serviceObserver: NSObjectProtocol?
    private var loadingError: Error?
    private let imagesListService: ImagesListService = .init()
    private let tableView: UITableView = .init()
    private let loadingIndicator: SomeLoadingIndicator = .shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObserver()
        loadSomeImages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imagesListService.cancelPendingFetchPhotos()
        loadingError = nil
    }
    
    private func loadSomeImages() {
        showLoadingIndicator()
        Task {
            do {
                try await imagesListService.fetchPhotosNextPage()
            } catch {
                print("Failed to load images: \(error)")
            }
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
            hideLoadingIndicator()
        }
    }
    
    private func setupObserver() {
        serviceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    @MainActor
    private func showLoadingIndicator() {
        loadingIndicator.show()
    }
    
    @MainActor
    private func hideLoadingIndicator() {
        loadingIndicator.hide()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        do {
            try imageListCell.loadPhoto(photo: imagesListService.photos[indexPath.row])
        } catch {
            print("Problem with cell config at row \(indexPath.row): \(error.localizedDescription)")
        }
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell, cell.isLoadedPhoto == true,
              let image = cell.cellImage.image else { return }
        coordinator?.showSingleImage(image: image, fullSizeUrlString: photos[indexPath.row].largeImageURL)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard photos.indices.contains(indexPath.row) else {
            print("Index out of bounds: tableView row \(indexPath.row), total photos count \(photos.count)")
            return UITableView.automaticDimension
        }
        let image = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImagesListCell else { return }
        
        let cellCenter = tableView.convert(cell.center, to: view)
        let scrollCenter = view.bounds.midY
        let maxOffset = view.bounds.height
        let relativeOffsetY = (cellCenter.y - scrollCenter) / maxOffset
        
        cell.parallax(offset: relativeOffsetY)
        
        if indexPath.row == photos.count - 1 {
            Task {
                do {
                    try await imagesListService.fetchPhotosNextPage()
                } catch {
                    hideLoadingIndicator()
                    loadingError = error
                    print("Error loading more photos: \(error.localizedDescription)")
                    await showAlert(error: error)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setParallax(scrollView: scrollView)
    }
    
    func showAlert(error: Error) async {
        if await showConfirmationAlert(
            title: "Что-то пошло не так",
            message: error.localizedDescription,
            cancelText: photos.isEmpty ? nil : "Ок",
            confirmActionText: "Выйти") {
            coordinator?.logout()
        }
    }
    
//    @MainActor
//    private func showErrorAlert(error: Error) {
//        let alert = UIAlertController(
//            title: "Что-то пошло не так",
//            message: error.localizedDescription,
//            preferredStyle: .alert
//        )
//        if !photos.isEmpty {
//            let cancelAction = UIAlertAction(title: "Ок", style: .cancel)
//            alert.addAction(cancelAction)
//        }
//        let exitAction = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
//            self?.coordinator?.logout()
//        }
//        alert.addAction(exitAction)
//
//        present(alert, animated: true)
//    }
    
    private func setParallax(scrollView: UIScrollView) {
        let visibleCells = tableView.visibleCells.compactMap { $0 as? ImagesListCell }
        for cell in visibleCells {
            let cellCenter = scrollView.convert(cell.center, to: view)
            let scrollCenter = view.bounds.midY
            let maxOffset = view.bounds.height
            let relativeOffsetY = (cellCenter.y - scrollCenter) / maxOffset
            cell.parallax(offset: relativeOffsetY)
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        Task { @MainActor in
            UIBlockingProgressHUD.show()
            cell.lockLikeButton(true)
            defer {
                UIBlockingProgressHUD.hide()
                cell.lockLikeButton(false)
            }
            do {
                cell.setIsLiked(to: !photo.isLiked)
                try await imagesListService.changeLikedState(ofPhotoWithId: photo.id, to: !photo.isLiked)
            } catch {
                cell.setIsLiked(to: photo.isLiked)
                print("Like error: \(error.localizedDescription)")
            }
        }
    }
}

extension ImagesListViewController {
    func setupTableView() {        
        tableView.backgroundColor = .ypBlack
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}
