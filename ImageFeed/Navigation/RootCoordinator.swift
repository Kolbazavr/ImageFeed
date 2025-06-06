//
//  RootCoordinator.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 05.06.2025.
//

import UIKit

final class RootCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let oAuthService: OAuth2Service
    private let window: UIWindow
    
    init(oAuth2Service: OAuth2Service = .shared, window: UIWindow) {
        self.oAuthService = oAuth2Service
        self.window = window
    }
    
    func start() {
        showSplash(with: nil)
        window.makeKeyAndVisible()
    }
    
    private func showAuthFlow() {
        print("Auth flow go!")
        let authCoordinator = AuthCoordinator(window: window)
        authCoordinator.coordinatorDelegate = self
        childCoordinators = [authCoordinator]
        authCoordinator.start()
    }
    
    private func showMainFlow() {
        print("Main flow go!")
        let feedCoordinator = FeedCoordinator(window: window)
        feedCoordinator.coordinatorDelegate = self
        childCoordinators = [feedCoordinator]
        feedCoordinator.start()
    }
    
    private func showSplash(with code: String?) {
        let splashVC = SplashVC()
        splashVC.delegate = self
        splashVC.tryToLogin(with: code)
        window.rootViewController = splashVC
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
        oAuthService.clearAccessToken()
        showSplash(with: nil)
    }
}

extension RootCoordinator: SplashViewControllerDelegate {
    func splashDidCheckLogin(isLoggedIn: Bool) { isLoggedIn ? showMainFlow() : showAuthFlow() }
}
