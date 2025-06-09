//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 01.05.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var rootCoordinator: RootCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        rootCoordinator = RootCoordinator(window: window)
        rootCoordinator?.start()
    }
}

