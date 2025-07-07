import UIKit

final class SplashVC: UIViewController {
    
    weak var delegate: SplashViewControllerDelegate?
    private let oAuthService = OAuth2Service.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
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
    
    func tryToLogin(with code: String?) async {
        showLoadingIndicator()
        do {
            if let code {
                try await fetchAndSaveOAuthToken(code)
                try await fetchUserProfileStuff(tokenStorage.accessToken)
                self.delegate?.splashDidCheckLogin(isLoggedIn: true)
            } else {
                try await fetchUserProfileStuff(tokenStorage.accessToken)
                self.delegate?.splashDidCheckLogin(isLoggedIn: tokenStorage.accessToken != nil)
            }
        } catch {
            hideLoadingIndicator()
            print("Error: \(error.localizedDescription)")
            if await showConfirmationAlert(title: "Что-то пошло не так(", message: "Не удалось войти в систему") {
                delegate?.splashDidCheckLogin(isLoggedIn: false)
            }
        }
        hideLoadingIndicator()
    }
    
    private func fetchAndSaveOAuthToken(_ code: String) async throws {
        let token = try await oAuthService.fetchOAuthToken(code: code)
        print("Received token: \(token)")
        tokenStorage.accessToken = token
    }
    
    private func fetchUserProfileStuff(_ token: String?) async throws {
        guard let token else { return } //no token? -> skip and go login
        try await profileService.fetchProfile(token: token)
        let username = profileService.profile?.username
        fetchProfileImageURL(username: username)
    }
    
    private func fetchProfileImageURL(username: String?) {
        Task {
            do {
                guard let username else { throw ProfileError.invalidUserName }
                try await profileImageService.fetchProfileImageURL(username: username)
            } catch {
                print("Failed to fetch profile image URL: \(error)")
            }
        }
    }
    
    @MainActor
    private func showLoadingIndicator() {
        UIBlockingProgressHUD.show()
    }
    
    @MainActor
    private func hideLoadingIndicator() {
        UIBlockingProgressHUD.hide()
    }
    
    private func setupUI() {
        view.addSubview(logoImageView)
        view.backgroundColor = .ypBlack
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 75),
            logoImageView.heightAnchor.constraint(equalToConstant: 77)
        ])
    }
}
