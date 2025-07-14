import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()

    override func setUpWithError() throws {

        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        // Given
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")
        
        // When
        loginTextField.tap()
        loginTextField.typeText("login@example.com")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        
        passwordTextField.tap()
        passwordTextField.typeText("password")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()

        // Then
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5), "Ячейка ленты не появилась после авторизации")
    }
    
    func testFeed() throws {
        let tablesQuery = app.tables
        
        let cell = tablesQuery.cells["feedCell_0"]
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.cells["feedCell_1"]
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 3))
        
        let likeButton = cellToLike.buttons["like button off"]
        XCTAssertTrue(likeButton.waitForExistence(timeout: 3))
        XCTAssertFalse(likeButton.isSelected)
        likeButton.tap()
        
        sleep(2)
        
        XCTAssertTrue(likeButton.isSelected)
        likeButton.tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["navBackButtonWhite"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        sleep(2)
        
        XCTAssertTrue(app.staticTexts["FirstName LastName"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
