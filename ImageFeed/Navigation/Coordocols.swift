//
//  Coordocols.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 05.06.2025.
//

//TODO: set to *Foundation* after UIImage changed to url or something:
import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}
extension Coordinator {
    func childDidFinish(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}

protocol AuthCoordinatorProtocol: Coordinator {
    var coordinatorDelegate: AuthCoordinatorDelegate? { get set }
    func showWebView()
    func didAuth(with code: String)
    func navigateBack()
}

protocol CoordinatedByAuthProtocol {
    var coordinator: AuthCoordinatorProtocol? { get set }
}

protocol FeedCoordinatorProtocol: Coordinator {
    func showSingleImage(image: UIImage)
    func logout()
}

protocol CoordinatedByFeedProtocol {
    var coordinator: FeedCoordinatorProtocol? { get set }
}

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidAuthThing(_ coordinator: AuthCoordinatorProtocol, with code: String)
}

protocol FeedCoordinatorDelegate: AnyObject {
    func feedCoordinatorDidLogout(_ coordinator: FeedCoordinatorProtocol)
}

protocol SplashViewControllerDelegate: AnyObject {
    func splashDidCheckLogin(isLoggedIn: Bool)
}
