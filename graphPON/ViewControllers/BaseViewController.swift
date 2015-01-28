import UIKit

class BaseViewController: UIViewController, PromptLoginPresenter, ErrorAlertPresenter {

    // MARK: - PromptLoginPresenter

    func presentPromptLoginControllerIfNeeded() {
        switch OAuth2Client.sharedClient.state {
        case OAuth2Client.AuthorizationState.UnAuthorized:
            if let _ = self.presentedViewController as? PromptLoginController {
                break
            }
            return self.presentViewController(
                PromptLoginController.alertController(),
                animated: true,
                completion: nil
            )
        default:
            break
        }
    }

    // MARK: - ErrorAlertPresenter

    func presentErrorAlertController(error: NSError) {
        self.presentViewController(
            ErrorAlertController.initWithError(error),
            animated: true,
            completion: nil
        )
    }

}
