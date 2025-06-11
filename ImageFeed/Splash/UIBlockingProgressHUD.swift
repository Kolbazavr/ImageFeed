//
//  UIBlockingProgressHUD.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 06.06.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    @MainActor
    static func show() {
        guard let window = window else { return }
        
        window.isUserInteractionEnabled = false
        ProgressHUD.animationType = .pacmanProgress
        ProgressHUD.colorHUD = .clear
        ProgressHUD.colorBackground = .ypBlack
        ProgressHUD.colorProgress = .ypBlack
        ProgressHUD.colorStatus = .ypBlack
        ProgressHUD.colorAnimation = .ypBlack
        ProgressHUD.animate()
    }
    
    @MainActor
    static func hide() {
        guard let window = window else { return }

        window.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
