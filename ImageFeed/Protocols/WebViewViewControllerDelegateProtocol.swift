import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
