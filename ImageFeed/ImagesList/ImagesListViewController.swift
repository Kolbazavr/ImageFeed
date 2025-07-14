import UIKit

protocol ImagesListViewProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var coordinator: FeedCoordinatorProtocol? { get set }
    var loadingIndicator: SomeLoadingIndicator { get }
    
    func updateTableViewAnimated(on rows: IndexSet)
    func showAlert(error: Error) async
}

final class ImagesListViewController: UIViewController, CoordinatedByFeedProtocol, ImagesListViewProtocol {
    weak var coordinator: FeedCoordinatorProtocol?
    var presenter: ImagesListPresenterProtocol?

    let loadingIndicator: SomeLoadingIndicator = .shared
    private let tableView: UITableView = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewWillDisappear()
    }
    
    func updateTableViewAnimated(on rows: IndexSet) {
        tableView.performBatchUpdates {
            let indexPaths = rows.map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.unsplashPhotos.count ?? 0
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
            try imageListCell.loadPhoto(photo: presenter?.unsplashPhotos[indexPath.row])
        } catch {
            print("Problem with cell config at row \(indexPath.row): \(error.localizedDescription)")
        }
        
        imageListCell.accessibilityIdentifier = "feedCell_\(indexPath.row)"
        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else { return }
        presenter?.didSelectImage(at: cell, with: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = presenter?.unsplashPhotos[indexPath.row] else { return UITableView.automaticDimension }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ImagesListCell else { return }
        setParallax(of: cell, for: tableView)
        
        if indexPath.row == (presenter?.unsplashPhotos.count ?? 0) - 1 {
            presenter?.didScrollToBottom()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = tableView.visibleCells.compactMap { $0 as? ImagesListCell }
        for cell in visibleCells {
            setParallax(of: cell, for: scrollView)
        }
    }
    
    func showAlert(error: Error) async {
        if await showConfirmationAlert(
            title: "Что-то пошло не так",
            message: error.localizedDescription,
            cancelText: (presenter?.unsplashPhotos.isEmpty ?? true) ? nil : "Ок",
            confirmActionText: "Выйти") {
            coordinator?.logout()
        }
    }
    
    private func setParallax(of cell: ImagesListCell ,for scrollView: UIScrollView) {
        let cellCenter = scrollView.convert(cell.center, to: view)
        let scrollCenter = view.bounds.midY
        let maxOffset = view.bounds.height
        let relativeOffsetY = (cellCenter.y - scrollCenter) / maxOffset
        cell.parallax(offset: relativeOffsetY)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLikeButton(at: cell, with: indexPath)
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
