//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by ANTON ZVERKOV on 07.07.2025.
//

@testable import ImageFeed
import XCTest

final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // Given
        let webViewController = WebViewViewController()
        let presenter = WebViewPresenterMock()
        webViewController.presenter = presenter
        presenter.view = webViewController
        
        // When
        _ = webViewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
        // Given
        let webViewControllerSpy = WebViewViewControllerMock()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(view: webViewControllerSpy, authHelper: authHelper)
        webViewControllerSpy.presenter = presenter
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(webViewControllerSpy.loadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        
        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        // Then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        // Given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        // When
        let url = authHelper.authRequest()?.url
        guard let urlString = url?.absoluteString else {
            XCTFail("URL string should not be nil")
            return
        }
        
        // Then
        XCTAssertTrue(urlString.contains("https://unsplash.com/oauth/authorize"))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        // Given
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper()
        
        // When
        let code = authHelper.code(from: url)
        
        // Then
        XCTAssertEqual(code, "test code")
    }
}
