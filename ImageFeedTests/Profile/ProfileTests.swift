@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let profileVC = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        profileVC.presenter = presenter
        
        _ = profileVC.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogout() {
        let profileVC = ProfileVCSpy()
        let presenter = ProfilePresenter(view: profileVC, service: ProfileServiceMock(), imageService: ProfileImageServiceMock())
        profileVC.presenter = presenter
        
        presenter.didTapLogout()
        
        let predicate = NSPredicate { _, _ in
            profileVC.confirmLogoutCalled
        }
        
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: profileVC)
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertTrue(profileVC.confirmLogoutCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        let profileVCSpy = ProfileVCSpy()
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let presenter = ProfilePresenter(view: profileVCSpy, service: profileService, imageService: profileImageService)
        profileVCSpy.presenter = presenter
        
        Task {
            try? await profileImageService.fetchProfileImageURL(username: "")
            try? await profileService.fetchProfile(token: "")
            await MainActor.run {
                presenter.viewDidLoad()
            }
        }
        
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
