import UIKit

class PromptLoginController: UIAlertController {

    class func alertController() -> PromptLoginController {
        let alert = PromptLoginController(
            title: NSLocalizedString("AuthentiacationRequired", comment: "Authentication prompt alert title"),
            message: NSLocalizedString("ThisApplicationRequiresUserAuthentication", comment: "User authentication required"),
            preferredStyle: UIAlertControllerStyle.Alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Open", comment: "Open"),
                style: UIAlertActionStyle.Default,
                handler: { action in
                    OAuth2Client.sharedClient.openOAuthAuthorizeURL()
                }
            )
        )
        return alert
    }

}
