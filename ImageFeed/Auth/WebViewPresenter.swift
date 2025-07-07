//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by ANTON ZVERKOV on 07.07.2025.
//

import Foundation

final class WebViewPresenter: WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    private let requestOMatic: RequestOMatic
    
    init(
        requestOMatic: RequestOMatic = RequestOMatic(clientID: Constants.accessKey, accessToken: nil),
        view: WebViewViewControllerProtocol? = nil,
        authHelper: AuthHelperProtocol
    ) {
        self.requestOMatic = requestOMatic
        self.view = view
        self.authHelper = authHelper
    }
    
    func viewDidLoad() {
//        view?.load(request: requestOMatic.request(for: .login))
        guard let request = authHelper.authRequest() else { return }
        view?.load(request: request)
        didUpdateProgressValue(0.0)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
