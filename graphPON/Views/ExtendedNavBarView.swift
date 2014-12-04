import UIKit

class ExtendedNavBarView: UIView {

    override func willMoveToWindow(newWindow: UIWindow?) {
        layer.shadowOffset = CGSizeMake(0, 1.0/UIScreen.mainScreen().scale)
        layer.shadowRadius = 0

        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.25
    }

}
