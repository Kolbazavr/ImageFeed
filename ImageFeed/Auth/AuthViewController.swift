import UIKit

final class AuthViewController: UIViewController, CoordinatedByAuthProtocol {
    
    weak var coordinator: AuthCoordinatorProtocol?
    
    private let loginButton = UIButton(type: .system)
    private let uselessLogo = UIImageView(image: UIImage(resource: .authScreenLogo))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    @objc private func loginButtonTapped() {
        coordinator?.showWebView()
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(didAuthenticateWithCode code: String) {
        coordinator?.didAuth(with: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        coordinator?.navigateBack()
    }
}

extension AuthViewController {
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        uselessLogo.contentMode = .scaleAspectFit
        
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        loginButton.backgroundColor = .ypWhite
        loginButton.tintColor = .ypBlack
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        loginButton.accessibilityIdentifier = "Authenticate"
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        [uselessLogo, loginButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            uselessLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            uselessLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            uselessLogo.heightAnchor.constraint(equalToConstant: 60),
            uselessLogo.widthAnchor.constraint(equalToConstant: 60),
            
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button_white")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button_white")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
    }
}
