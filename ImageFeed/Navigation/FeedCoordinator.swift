//
//  FeedCoordinator.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 05.06.2025.
//

import UIKit

final class FeedCoordinator: FeedCoordinatorProtocol {
    weak var coordinatorDelegate: FeedCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    deinit {
        print("FeedCoordinator deinit")
    }
    
    func start() {
        let tabBarController = UITabBarController()
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .ypBlack
        
        tabBarController.tabBar.standardAppearance = tabAppearance
        if #available(iOS 15.0, *) { tabBarController.tabBar.scrollEdgeAppearance = tabAppearance }
        
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.barTintColor = .ypBlack
        tabBarController.tabBar.tintColor = .ypWhite
        
        tabBarController.viewControllers = [createImageListNav(), createProfileNav()]
        window.rootViewController = tabBarController
    }
    
    func showSingleImage(image: UIImage, fullSizeUrlString: String) {
        let singleImageVC = SingleImageViewController(largeImageURL: fullSizeUrlString, image: image)
        let navigationController = UINavigationController(rootViewController: singleImageVC)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.modalTransitionStyle = .flipHorizontal
        window.rootViewController?.present(navigationController, animated: true)
    }
    
    func logout() {
        coordinatorDelegate?.feedCoordinatorDidLogout(self)
    }
    
    private func createImageListNav() -> UINavigationController {
        let imageListVC = ImagesListViewController()
        imageListVC.coordinator = self
        let imageListNavController = UINavigationController(rootViewController: imageListVC)
        imageListNavController.navigationBar.isHidden = true
        imageListNavController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditoralNoActive).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(resource: .tabEditoralActive).withRenderingMode(.alwaysOriginal)
        )
        return imageListNavController
    }
    
    private func createProfileNav() -> UINavigationController {
        let profileVC = ProfileViewController()
        profileVC.coordinator = self
        let profileNavController = UINavigationController(rootViewController: profileVC)
        profileNavController.navigationBar.isHidden = true
        profileNavController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileNoActive).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(resource: .tabProfileActive).withRenderingMode(.alwaysOriginal)
        )
        return profileNavController
    }
}
