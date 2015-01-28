import UIKit

@objc protocol ErrorAlertPresenter {
    func presentErrorAlertController(error: NSError)
}
