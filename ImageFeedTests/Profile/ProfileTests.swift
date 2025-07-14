@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let profileVC = ProfileViewController()
        let presenter = ProfilePresenterMock()
        profileVC.presenter = presenter
        
        // When
        _ = profileVC.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled, "Ожидается вызов viewDidLoad() у презентера")
    }
    
    func testLogout() {
        // Given
        let profileVC = ProfileVCMock()
        let presenter = ProfilePresenter(
            view: profileVC,
            service: ProfileServiceMock(),
            imageService: ProfileImageServiceMock()
        )
        profileVC.presenter = presenter
        
        // When
        presenter.didTapLogout()
        
        // Then
        let predicate = NSPredicate { _, _ in profileVC.confirmLogoutCalled }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: profileVC)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(profileVC.confirmLogoutCalled, "Ожидается вызов confirmLogout() у вью")
    }
    
    func testPresenterCallsUpdateAvatar() {
        // Given
        let profileVCSpy = ProfileVCMock()
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfilePresenter(
            view: profileVCSpy,
            service: profileService,
            imageService: profileImageService
        )
        profileVCSpy.presenter = presenter
        
        Task {
            try? await profileImageService.fetchProfileImageURL(username: "")
            try? await profileService.fetchProfile(token: "")
            await MainActor.run {
                // When
                presenter.viewDidLoad()
            }
        }
        
        // Then
        let predicate = NSPredicate { _, _ in profileVCSpy.updateAvatarCalled }
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: profileVCSpy)
        
        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(result, .completed)
        XCTAssertTrue(profileVCSpy.updateAvatarCalled)
        XCTAssertTrue(profileVCSpy.updateProfileDetailsCalled)
    }
}
