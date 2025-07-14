@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let imagesListVC = ImagesListViewController()
        let presenter = ImagesListPresenterMock()
        imagesListVC.presenter = presenter
        presenter.view = imagesListVC
        
        // When
        _ = imagesListVC.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterFetchesImages() {
        // Given
        let imagesListVC = ImagesListVCMock()
        let presenter = ImagesListPresenter(view: imagesListVC, service: ImagesListService(fetcher: ImagesListFetcherMock()))
        imagesListVC.presenter = presenter
        
        // When
        presenter.viewDidLoad()
        
        // Then
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
        // Given
        let imagesListVC = ImagesListVCMock()
        let presenter = ImagesListPresenter(view: imagesListVC, service: ImagesListService(fetcher: ImagesListFetcherMock(getsError: true)))
        imagesListVC.presenter = presenter
        
        // When
        presenter.viewDidLoad()
        
        // Then
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
