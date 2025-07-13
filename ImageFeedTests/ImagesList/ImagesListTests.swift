@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let imagesListVC = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        imagesListVC.presenter = presenter
        presenter.view = imagesListVC
        
        _ = imagesListVC.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterFetchesImages() {
        let imagesListVC = ImagesListVCSpy()
        let presenter = ImagesListPresenter(view: imagesListVC, service: ImagesListService(fetcher: ImagesListFetcherMock()))
        imagesListVC.presenter = presenter
        
        presenter.viewDidLoad()
        
        let predicate = NSPredicate { _, _ in
            !presenter.unsplashPhotos.isEmpty
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: presenter)
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed)
        XCTAssertFalse(presenter.unsplashPhotos.isEmpty)
        XCTAssertTrue(imagesListVC.upateTableViewAnimatedCalledCount == 1)
        XCTAssertTrue(presenter.unsplashPhotos[0].id == "TestPhotoId1")
    }
    
    func testPresenterShowsErrorWhenFetchingImagesFails() {
        let imagesListVC = ImagesListVCSpy()
        let presenter = ImagesListPresenter(view: imagesListVC, service: ImagesListService(fetcher: ImagesListFetcherMock(getsError: true)))
        imagesListVC.presenter = presenter
        
        presenter.viewDidLoad()
        
        let predicate = NSPredicate { _, _ in
            imagesListVC.alertShowen
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: presenter)
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        XCTAssertEqual(result, .completed)
        XCTAssertTrue(imagesListVC.alertShowen)
        XCTAssertTrue(imagesListVC.loadingError!.localizedDescription == "HTTP status code: 404")
    }
}
