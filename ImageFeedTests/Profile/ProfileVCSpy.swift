@testable import ImageFeed
import Foundation

final class ProfileVCSpy: ProfileViewProtocol {
    var updateAvatarCalled = false
    var updateProfileDetailsCalled = false
    var confirmLogoutCalled = false
    
    var presenter: (any ImageFeed.ProfilePresenterProtocol)?
    var coordinator: (any ImageFeed.FeedCoordinatorProtocol)?
    var loadingIndicator: ImageFeed.SomeLoadingIndicator = SomeLoadingIndicator.shared
    
    func updateAvatar(from url: URL) {
        updateAvatarCalled = true
    }
    
    func updateProfileDetails(profile: ImageFeed.UnsplashUser) {
        updateProfileDetailsCalled = true
    }
    
    func confirmLogout() async -> Bool {
        confirmLogoutCalled = true
        return false
    }
}
