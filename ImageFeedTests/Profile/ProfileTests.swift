@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let profileVC = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        profileVC.presenter = presenter
        
        // When
        _ = profileVC.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogout() {
        // Given
        let profileVC = ProfileVCSpy()
        let presenter = ProfilePresenter(view: profileVC, service: ProfileServiceMock(), imageService: ProfileImageServiceMock())
        profileVC.presenter = presenter
        
        // When
        presenter.didTapLogout()
        
        // Then
        let predicate = NSPredicate { _, _ in
            profileVC.confirmLogoutCalled
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: profileVC)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(profileVC.confirmLogoutCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        // Given
        let profileVCSpy = ProfileVCSpy()
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfilePresenter(view: profileVCSpy, service: profileService, imageService: profileImageService)
        profileVCSpy.presenter = presenter
        
        // When
        Task {
            try? await profileImageService.fetchProfileImageURL(username: "")
            try? await profileService.fetchProfile(token: "")
            await MainActor.run {
                presenter.viewDidLoad()
            }
        }
        
        // Then
        let predicate = NSPredicate { _, _ in
            profileVCSpy.updateAvatarCalled
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: profileVCSpy)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(result, .completed)
        XCTAssertTrue(profileVCSpy.updateAvatarCalled)
        XCTAssertTrue(profileVCSpy.updateProfileDetailsCalled)
    }
}
