@testable import ImageFeed
import Foundation

final class ImagesListVCMock: ImagesListViewProtocol {
    var upateTableViewAnimatedCalledCount = 0
    var alertShowen: Bool = false
    var loadingError: Error?
    
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    var coordinator: ImageFeed.FeedCoordinatorProtocol?
    var loadingIndicator: ImageFeed.SomeLoadingIndicator = .shared
    
    func updateTableViewAnimated(on rows: IndexSet) {
        upateTableViewAnimatedCalledCount += 1
        print(upateTableViewAnimatedCalledCount)
    }
    
    func showAlert(error: any Error) async {
        loadingError = error
        alertShowen = true
    }
}
