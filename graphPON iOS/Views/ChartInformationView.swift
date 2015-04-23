import UIKit

class ChartInformationView: UIView {

    @IBOutlet private var titleLabel: UILabel! = UILabel()
    private let kJBChartValueViewPadding = CGFloat(0.0)
    private let kJBChartValueViewSeparatorSize = CGFloat(0.5)
    private let kJBChartValueViewTitleHeight = CGFloat(50.0)

    func setHidden(hidden: Bool, animated: Bool) {
        if animated {
            if hidden {
                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    self.titleLabel.alpha = 0.0
                }, completion:nil)
            } else {
                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    self.titleLabel.alpha = 1.0
                 }, completion:nil)
            }
        } else {
            self.titleLabel.alpha = hidden ? 0.0 : 1.0
        }
    }

    func setTitleText(titleText: String) {
        self.titleLabel.text = titleText
    }

}
