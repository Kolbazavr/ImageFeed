import UIKit

extension UIViewController {
    
    @MainActor
    func showConfirmationAlert(title: String, message: String, cancelText: String? = nil, confirmActionText: String? = nil) async -> Bool {
        await withCheckedContinuation { continuation in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if let confirmActionText {
                alertController.addAction(UIAlertAction(title: confirmActionText, style: .default) { _ in
                    continuation.resume(returning: true)
                })
            }
            if let cancelText {
                alertController.addAction(UIAlertAction(title: cancelText, style: .default) { _ in
                    continuation.resume(returning: false)
                })
            }
            //like default thing (TRUE -> do action)
            if alertController.actions.isEmpty {
                alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    continuation.resume(returning: true)
                })
            }
            present(alertController, animated: true)
        }
    }
}
