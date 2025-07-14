@testable import ImageFeed
import Foundation

final class ImagesListPresenterMock: ImagesListPresenterProtocol {
    var viewDidLoadCalled = false
    var didScrollToBottomCalled = false
    
    var view: ImageFeed.ImagesListViewProtocol?
    
    var unsplashPhotos: [ImageFeed.Photo] = []
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func viewWillDisappear() { }
    
    func didSelectImage(at cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) { }
    
    func didTapLikeButton(at cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) { }
    
    func didScrollToBottom() {
        didScrollToBottomCalled = true
    }
}
