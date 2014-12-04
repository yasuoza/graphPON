import UIKit

class ChartInformationView: UIView {

    private let titleLabel: UILabel = UILabel()
    private let kJBChartValueViewPadding = CGFloat(10.0)
    private let kJBChartValueViewSeparatorSize = CGFloat(0.5)
    private let kJBChartValueViewTitleHeight = CGFloat(50.0)


    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.addSubview(titleLabel)
    }

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        self.titleLabel.frame = CGRectMake(
            ceil(kJBChartValueViewPadding / 2),
            0,
            self.frame.width - ceil(kJBChartValueViewPadding * 2),
            self.frame.height - kJBChartValueViewPadding * 2
        )
        titleLabel.text = "FIX TEXT LATER"
    }

    func setHidden(hidden: Bool, animated: Bool) {
        if animated {
            if hidden {
                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    self.titleLabel.alpha = 0.0
                }, completion: { finished in
                        self.titleLabel.frame = self.titleViewRectForHidden(hidden)
                })
            } else {
                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    self.titleLabel.frame = self.titleViewRectForHidden(hidden)
                    self.titleLabel.alpha = 1.0
                 }, completion:nil)
            }
        } else {
            self.titleLabel.alpha = hidden ? 0.0 : 1.0
            self.titleLabel.frame = self.titleViewRectForHidden(hidden)
        }
    }

    func setHidden(hidden: Bool) {
        setHidden(hidden, animated: false)
    }

    func setTitleText(titleText: String) {
        self.titleLabel.text = titleText
    }

    // MARK: - Private 

    private func titleViewRectForHidden(hidden: Bool) -> CGRect {
        var titleRect = CGRectZero
        titleRect.origin.x = ceil(kJBChartValueViewPadding / 2)
        titleRect.origin.y = hidden ? 0 : kJBChartValueViewPadding / 2
        titleRect.size.width = self.bounds.size.width - (kJBChartValueViewPadding * 2)
        titleRect.size.height = self.frame.height - kJBChartValueViewPadding * 2
        return titleRect
    }

}
