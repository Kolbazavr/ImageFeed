//
//  SplashVC.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 06.06.2025.
//

import UIKit
import ProgressHUD

final class SplashVC: UIViewController {
    
    weak var delegate: SplashViewControllerDelegate?
    private let oAuthService = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private let logoImageView: UIImageView = {
        let image = UIImage(resource: .splashScreenLogo)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func tryToLogin(with code: String?) {
        if let code {
            fetchOAuthToken(code)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let isLoggedIn = self.oAuthService.isLoggedIn
                self.delegate?.splashDidCheckLogin(isLoggedIn: isLoggedIn)
            }
        }
    }
    
    private func fetchAndSaveOAuthToken(_ code: String) async throws {
        let token = try await oAuthService.fetchOAuthToken(code: code)
        print("Received token: \(token)")
        tokenStorage.accessToken = token
    }
    
    private func fetchOAuthToken(_ code: String) {
        Task { @MainActor in
            do {
                ProgressHUD.animate()
                try await fetchAndSaveOAuthToken(code)
                ProgressHUD.dismiss()
                tryToLogin(with: nil)
            } catch {
                ProgressHUD.dismiss()
                showErrorAlert(error: error)
                print("Failed to fetch token: \(error)")
            }
        }
    }
    
    private func showErrorAlert(error: Error) {
        let alert = UIAlertController(
            title: "Something went wrong:",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Okay", style: .default))
        present(alert, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        view.backgroundColor = .ypBlack
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        ProgressHUD.animationType = .pacmanProgress
        ProgressHUD.colorHUD = .clear
        ProgressHUD.colorBackground = .ypBlack
        ProgressHUD.colorProgress = .ypBlack
        ProgressHUD.colorStatus = .ypBlack
        ProgressHUD.colorAnimation = .ypBlack
    }
}
