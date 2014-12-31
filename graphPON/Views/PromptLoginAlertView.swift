import UIKit

class PromptLoginAlertView: UIAlertView {

    class func initWithPreset(delegate _delegate: UIAlertViewDelegate) -> UIAlertView! {
        return UIAlertView(
            title: "Login to Iijmio",
            message: "Tap login button to open Iijmio service login window",
            delegate: _delegate,
            cancelButtonTitle: nil,
            otherButtonTitles: "Login"
        )
    }

}
