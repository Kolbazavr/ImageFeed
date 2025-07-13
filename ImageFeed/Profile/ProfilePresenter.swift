import Foundation
import WebKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewProtocol?
    private let service: ProfileServiceProtocol
    private let imageService: ProfileImageServiceProtocol
    private var serviceObserver: NSObjectProtocol?
    
    init(view: ProfileViewProtocol, service: ProfileServiceProtocol, imageService: ProfileImageServiceProtocol) {
        self.view = view
        self.service = service
        self.imageService = imageService
        addServiceObserver(for: service)
    }
    
    deinit { if let observer = serviceObserver { NotificationCenter.default.removeObserver(observer) } }
    
    func viewDidLoad() {
        //
        updateAvatar(from: imageService.avatarURL)
        updateProfileDetails()
    }
    
    func didTapLogout() {
        Task {
            guard let view else { return }
            if await view.confirmLogout() { await didConfirmedLogout() }
        }
    }
    
    private func addServiceObserver(for service: ProfileServiceProtocol) {
        serviceObserver = NotificationCenter.default
            .addObserver(
                forName: imageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self else { return }
                self.updateAvatar(from: notification)
            }
    }
    
    private func updateAvatar(from notification: Notification) {
        let avatarURL = notification.userInfo?["URL"] as? URL
        updateAvatar(from: avatarURL)
    }
    
    private func updateAvatar(from url: URL?) {
        guard let url else { return }
        view?.updateAvatar(from: url)
    }
    
    private func updateProfileDetails() {
        guard let profile = service.profile else { return }
        view?.updateProfileDetails(profile: profile)
    }
    
    @MainActor
    private func didConfirmedLogout() async {
        showLoadingIndicator()
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        let cookies = await cookieStore.allCookies()
        for cookie in cookies { await cookieStore.deleteCookie(cookie) }
        
        let websiteDataTypes = Set([WKWebsiteDataTypeCookies, WKWebsiteDataTypeLocalStorage])
        await WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: Date.distantPast)
        
        OAuth2Service.shared.clearAccessToken()
        hideLoadingIndicator()
        view?.coordinator?.logout()
    }
    
    @MainActor
    private func showLoadingIndicator() {
        view?.loadingIndicator.show()
    }
    
    @MainActor
    private func hideLoadingIndicator() {
        view?.loadingIndicator.hide()
    }
}
