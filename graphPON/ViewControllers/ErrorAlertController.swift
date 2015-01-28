import UIKit

class ErrorAlertController: UIAlertController {

    class func initWithError(error: NSError) -> ErrorAlertController {
        let (title, message) = self.buildTitleAndMessageFromError(error)
        let alert = ErrorAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        return alert
    }


    private class func buildTitleAndMessageFromError(error: NSError) -> (String, String) {
        switch error.domain {
        case String(OAuth2Router.APIErrorDomain):
            switch error.code {
            case Int(OAuth2Router.AuthorizationFailureErrorCode):
                let title = NSLocalizedString("AuthenticationFailed", comment: "Authentication failed alert title")
                let message = NSLocalizedString("AuthorizationFailedPleaseLoginIIJmio", comment: "Authorization falied alert message")
                return (title, message)
            case Int(OAuth2Router.TooManyRequestErrorCode):
                let title = NSLocalizedString("TooManyRequest", comment: "Too many request alert title")
                let message = NSLocalizedString("TooManyRequestPleaseRequestLater", comment: "Too many request alert message")
                return (title, message)
            default:
                let title = NSLocalizedString("UnknownError", comment: "Unknown error alert title")
                let message = NSLocalizedString("UnknownErrorHappendPleaseRequestLater", comment: "Unkown error alert message")
                return (title, message)
            }
        default:
            let title = NSLocalizedString("RequestFailed", comment: "Request failed error alert title")
            let message = NSLocalizedString("PleaseCheckNetworkConnectionAndMakeRequestOnceAgain", comment: "Request failed error alert message")
            return (title, message)
        }
    }

}
