import Foundation
import ProgressHUD

protocol LoadingIndicator {
    func show()
    func hide()
}

final class SomeLoadingIndicator: LoadingIndicator {
    static let shared = SomeLoadingIndicator()
    
    private init() {
        ProgressHUD.colorHUD = .clear
        ProgressHUD.colorBackground = .ypBlack
        ProgressHUD.colorProgress = .ypBlack
        ProgressHUD.colorStatus = .ypBlack
        ProgressHUD.colorAnimation = .ypBlack
    }
    
    func show() {
        ProgressHUD.animate()
    }
    
    func hide() {
        ProgressHUD.dismiss()
    }
}
