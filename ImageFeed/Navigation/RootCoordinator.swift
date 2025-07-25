import UIKit

final class RootCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        showSplash(with: nil)
        window.makeKeyAndVisible()
    }
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(window: window)
        authCoordinator.coordinatorDelegate = self
        childCoordinators = [authCoordinator]
        authCoordinator.start()
    }
    
    private func showMainFlow() {
        let feedCoordinator = FeedCoordinator(window: window)
        feedCoordinator.coordinatorDelegate = self
        childCoordinators = [feedCoordinator]
        feedCoordinator.start()
    }
    
    private func showSplash(with code: String?) {
        let splashVC = SplashVC()
        splashVC.delegate = self
        window.rootViewController = splashVC
        Task { @MainActor in
            await splashVC.tryToLogin(with: code)
        }
    }
}

extension RootCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidAuthThing(_ coordinator: AuthCoordinatorProtocol, with code: String) {
        childDidFinish(coordinator)
        showSplash(with: code)
    }
}

extension RootCoordinator: FeedCoordinatorDelegate {
    func feedCoordinatorDidLogout(_ coordinator: FeedCoordinatorProtocol) {
        childDidFinish(coordinator)
        showSplash(with: nil)
    }
}

extension RootCoordinator: SplashViewControllerDelegate {
    func splashDidCheckLogin(isLoggedIn: Bool) { isLoggedIn ? showMainFlow() : showAuthFlow() }
}
