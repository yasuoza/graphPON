import UIKit

class PromptLoginController: UIAlertController {

    class func alertController() -> PromptLoginController {
        let alert = PromptLoginController(
            title: NSLocalizedString("AuthentiacationRequired", comment: "Authentication prompt alert title"),
            message: NSLocalizedString("ThisApplicationRequiresUserAuthentication", comment: "User authentication required"),
            preferredStyle: .Alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Open", comment: "Open"),
                style: UIAlertActionStyle.Default,
                handler: { action in
                    UIApplication.sharedApplication().openURL(OAuth2Router.Authorize.URLRequest.URL)
                    return
                }
            )
        )
        return alert
    }

}
