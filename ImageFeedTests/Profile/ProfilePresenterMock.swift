@testable import ImageFeed
import Foundation

final class ProfilePresenterMock: ProfilePresenterProtocol {
    var viewDidLoadCalled = false
    var didTapLogoutCalled = false
    var view: (any ImageFeed.ProfileViewProtocol)?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
}
