import UIKit
import ProgressHUD

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let oauth2Service = OAuth2Service.shared
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func fetchAndSaveOAuthToken(_ code: String) async throws {
        let token = try await oauth2Service.fetchOAuthToken(code: code)
        print("Received token: \(token)")
        tokenStorage.accessToken = token
    }
    
    private func fetchOAuthToken(_ code: String) {
        Task { @MainActor in
            do {
                ProgressHUD.animate()
                try await fetchAndSaveOAuthToken(code)
                ProgressHUD.dismiss()
                delegate?.authViewController(self, didAuthenticateWithCode: code)
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
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popViewController(animated: true)
        fetchOAuthToken(code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}

extension AuthViewController {
    private func setupUI() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button_white")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button_white")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .ypBlack
        
        ProgressHUD.animationType = .pacmanProgress
        ProgressHUD.colorHUD = .yellow
        ProgressHUD.colorBackground = .clear
    }
}
