import UIKit

public protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}
extension Coordinator {
    func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}

public protocol AuthCoordinatorProtocol: Coordinator {
    var coordinatorDelegate: AuthCoordinatorDelegate? { get set }
    func showWebView()
    func didAuth(with code: String)
    func navigateBack()
}

public protocol CoordinatedByAuthProtocol {
    var coordinator: AuthCoordinatorProtocol? { get set }
}

public protocol FeedCoordinatorProtocol: Coordinator {
    func showSingleImage(image: UIImage, fullSizeUrlString: String)
    func logout()
}

public protocol CoordinatedByFeedProtocol {
    var coordinator: FeedCoordinatorProtocol? { get set }
}

public protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidAuthThing(_ coordinator: AuthCoordinatorProtocol, with code: String)
}

public protocol FeedCoordinatorDelegate: AnyObject {
    func feedCoordinatorDidLogout(_ coordinator: FeedCoordinatorProtocol)
}

public protocol SplashViewControllerDelegate: AnyObject {
    func splashDidCheckLogin(isLoggedIn: Bool)
}
