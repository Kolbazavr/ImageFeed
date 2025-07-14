//
//  AuthCoordinator.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 05.06.2025.
//

import UIKit

final class AuthCoordinator: AuthCoordinatorProtocol {
    weak var coordinatorDelegate: AuthCoordinatorDelegate?
    var navigationController: UINavigationController!

    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    deinit {
        print("AuthCoordinator deinit")
    }
    
    func start() {
        let authViewController = AuthViewController()
        authViewController.coordinator = self
        
        navigationController = UINavigationController(rootViewController: authViewController)
        window.rootViewController = navigationController
    }
    
    func showWebView() {
        let webViewController = WebViewViewController()
        let authHelper = AuthHelper()
        
        let webViewPresenter = WebViewPresenter(view: webViewController, authHelper: authHelper)
        webViewController.presenter = webViewPresenter
        
        webViewController.delegate = navigationController.topViewController as? WebViewViewControllerDelegate
        navigationController.pushViewController(webViewController, animated: true)
    }
    
    func didAuth(with code: String) {
        coordinatorDelegate?.authCoordinatorDidAuthThing(self, with: code)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
