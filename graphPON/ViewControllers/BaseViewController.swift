import UIKit

class BaseViewController: UIViewController, PromptLoginPresenter {

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

}
