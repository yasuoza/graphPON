import UIKit

class PromptLoginController: UIAlertController {

    class func alertController() -> PromptLoginController {
        let alert = PromptLoginController(
            title: "Authentiacation required",
            message: "This application requires Iijmio authentication. Open login page and please login.",
            preferredStyle: UIAlertControllerStyle.Alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Open",
                style: UIAlertActionStyle.Default,
                handler: { action in
                    OAuth2Client.sharedClient.openOAuthAuthorizeURL()
                }
            )
        )
        return alert
    }

}
