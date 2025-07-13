import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewProtocol? { get set }
    var unsplashPhotos: [Photo] { get }
    
    func viewDidLoad()
    func viewWillDisappear()
    func didSelectImage(at cell: ImagesListCell, with indexPath: IndexPath)
    func didTapLikeButton(at cell: ImagesListCell, with indexPath: IndexPath)
    func didScrollToBottom()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    var unsplashPhotos: [Photo] = []
    private var loadingError: Error?
    private var serviceObserver: NSObjectProtocol?
    private let service: ImagesListServiceProtocol
    
    init(view: ImagesListViewProtocol, service: ImagesListServiceProtocol) {
        self.view = view
        self.service = service
        addServiceObserver(for: service)
    }
    
    //check if this needed:
    deinit { if let observer = serviceObserver { NotificationCenter.default.removeObserver(observer) } }
    
    func viewDidLoad() {
        didScrollToBottom()
    }
    
    func viewWillDisappear() {
        loadingError = nil
        service.cancelPendingFetchPhotos()
    }
    
    func didSelectImage(at cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = cell.cellImage.image, cell.isLoadedPhoto else { return }
        view?.coordinator?.showSingleImage(image: image, fullSizeUrlString: unsplashPhotos[indexPath.row].largeImageURL)
    }
    
    func didTapLikeButton(at cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = unsplashPhotos[indexPath.row]
        Task {
            await cell.lockLikeButton(true)
            await showLoadingIndicator()
            await cell.setIsLiked(to: !photo.isLiked)
            do {
                try await self.service.changeLikedState(ofPhotoWithId: photo.id, to: !photo.isLiked)
            } catch {
                await cell.setIsLiked(to: photo.isLiked)
                print("Error changing liked state: \(error)")
            }
            await cell.lockLikeButton(false)
            await hideLoadingIndicator()
        }
    }
    
    func didScrollToBottom() {
        Task {
            do {
                try await fetchFotosNextPage()
                await hideLoadingIndicator()
            } catch {
                await showAlert(error: error)
                await hideLoadingIndicator()
            }
        }
    }
    
    private func fetchFotosNextPage() async throws {
        guard loadingError == nil else { return }
        await showLoadingIndicator()
        try await service.fetchPhotosNextPage()
    }
    
    private func newPhotosReceived() {
        let oldCount = self.unsplashPhotos.count
        let newCount = self.service.photos.count
        self.unsplashPhotos = service.photos
        
        if oldCount != newCount {
            let newPhotosIndexSet = IndexSet(integersIn: oldCount..<newCount)
            self.view?.updateTableViewAnimated(on: newPhotosIndexSet)
        }
    }
    
    private func addServiceObserver(for service: ImagesListServiceProtocol) {
        serviceObserver = NotificationCenter.default.addObserver(
            forName: service.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
            self?.newPhotosReceived()
        })
    }
    
    @MainActor
    private func showAlert(error: Error) async {
        self.loadingError = error
        await view?.showAlert(error: error)
    }
    
    @MainActor
    private func showLoadingIndicator() {
        view?.loadingIndicator.show()
    }
    
    @MainActor
    private func hideLoadingIndicator() {
        view?.loadingIndicator.hide()
    }
}
