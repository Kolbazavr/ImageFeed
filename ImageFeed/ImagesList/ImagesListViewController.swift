import UIKit
import ProgressHUD

final class ImagesListViewController: UIViewController, CoordinatedByFeedProtocol {
    
    weak var coordinator: FeedCoordinatorProtocol?
    
    private let tableView: UITableView = .init()
    
    //TODO: Temporary (update later):
    private let fetchyFetcher: FetchyFetcher = .init(accessToken: OAuth2TokenStorage.shared.accessToken)
    private var someUnsplashPhotos: [UnsplashPhoto] = []
    private var alreadyLoadedPages: Set<Int> = []
    private var photoIdentifiers: Set<String> = []
    private var loadingTask: Task<Void, Error>?
    private var loadingError: Error?
    private let distanceToBottomForLoadingMore: CGFloat = 200
    //----------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        Task {
            do {
                try await loadSomeImages()
            } catch {
                print("Failed to load images: \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingTask?.cancel()
        loadingError = nil
    }
    
    //TODO: Temporary (update later):
    private func loadSomeImages() async throws {
        showLoadingIndicator()
        if let existingLoadingTask = loadingTask {
//            print("Request to load rejected: already in progress...")
            try await existingLoadingTask.value
        } else {
            let newLoadingTask = Task {
                defer { self.loadingTask = nil }
                let pageToLoad = (alreadyLoadedPages.max() ?? 0) + 1
                let loadedPhotos: [UnsplashPhoto] = try await fetchyFetcher.fetch(.photoPage(page: pageToLoad, perPage: 10))
                let filteredPhotos: [UnsplashPhoto] = loadedPhotos.filter { !photoIdentifiers.contains($0.identifier) }
                
                insertLoadedPhotos(filteredPhotos, forPage: pageToLoad)
            }
            loadingTask = newLoadingTask
            try await newLoadingTask.value
        }
    }
    
    @MainActor
    private func insertLoadedPhotos(_ photos: [UnsplashPhoto], forPage page: Int) {
        photoIdentifiers.formUnion(photos.map { $0.identifier })

        let startIndex = someUnsplashPhotos.count
        someUnsplashPhotos.append(contentsOf: photos)
        alreadyLoadedPages.insert(page)

        let indexPaths = (startIndex..<someUnsplashPhotos.count).map { IndexPath(row: $0, section: 0) }
        
        //                print("Loaded \(loadedPhotos.count) photos on page \(pageToLoad), added after dubplicates filtering: \(filteredPhotos.count). total loaded: \(someUnsplashPhotos.count)")

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }

        hideLoadingIndicator()
    }
    
    @MainActor
    private func showLoadingIndicator() {
        ProgressHUD.animate()
    }
    
    @MainActor
    private func hideLoadingIndicator() {
        ProgressHUD.dismiss()
    }
    //----------------------------
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        someUnsplashPhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        do {
            try imageListCell.loadPhoto(photo: someUnsplashPhotos[indexPath.row], isLiked: indexPath.row % 2 == 0)
        } catch {
            print("Problem with cell config at row \(indexPath.row): \(error)")
        }
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell,
              let image = cell.cellImage.image else { return }
        coordinator?.showSingleImage(image: image)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard someUnsplashPhotos.indices.contains(indexPath.row) else {
            print("Index out of bounds: tableView row \(indexPath.row), total photos count \(someUnsplashPhotos.count)")
            return UITableView.automaticDimension
        }
        let image = someUnsplashPhotos[indexPath.row]
        
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
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setParallax(scrollView: scrollView)
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY >= (contentHeight - height - distanceToBottomForLoadingMore) {
            guard loadingError == nil else { return }
            guard loadingTask == nil else { return }
//            print("ScrollView did scroll to bottom. Asking to load more... Photos total count: \(someUnsplashPhotos.count)")
            Task {
                do {
                    try await loadSomeImages()
                } catch {
                    hideLoadingIndicator()
                    loadingError = error
                    showErrorAlert(error: error)
                    print("Error loading more photos: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        if !someUnsplashPhotos.isEmpty {
            let cancelAction = UIAlertAction(title: "Ок", style: .cancel)
            alert.addAction(cancelAction)
        }
        let exitAction = UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.coordinator?.logout()
        }
        alert.addAction(exitAction)
        
        present(alert, animated: true)
    }
    
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

extension ImagesListViewController {
    func setupTableView() {
        ProgressHUD.animationType = .pacmanProgress
        ProgressHUD.colorHUD = .clear
        ProgressHUD.colorBackground = .ypBlack
        ProgressHUD.colorProgress = .ypBlack
        ProgressHUD.colorStatus = .ypBlack
        ProgressHUD.colorAnimation = .ypBlack
        
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
