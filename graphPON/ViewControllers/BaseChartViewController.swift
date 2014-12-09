import UIKit

class BaseChartViewController: UIViewController {

    enum Mode {
        case Daily, Summary

        func backgroundColor() -> UIColor {
            switch self {
            case .Daily:
                return UIColor(hex: "ca9asc")
            case .Summary:
                return UIColor(red: 0.369, green: 0.408, blue: 0.686, alpha: 1.0)
            }
        }

        func titleText() -> String {
            switch self {
            case .Daily:
                return "Daily Total"
            case .Summary:
                return "Summary"
            }
        }
    }

    @IBOutlet weak var chartViewContainerView: ChartViewContainerView!

    var tooltipView: ChartTooltipView = ChartTooltipView()
    var tooltipTipView: ChartTooltipTipView = ChartTooltipTipView()

    override func viewDidLoad() {
        super.viewDidLoad()

        

//        self.tabBarItem.setTitleTextAttributes(
//            [NSForegroundColorAttributeName: UIColor.whiteColor()],
//            forState: UIControlState.Normal
//        )

        self.tooltipView.alpha = 0.0
        self.chartViewContainerView.addSubview(self.tooltipView)

        self.tooltipTipView.alpha = 0.0
        self.chartViewContainerView.addSubview(self.tooltipTipView)

        // Hide navigation bar bottom line
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "TransparentPixel")
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage(named: "Pixel"),
            forBarMetrics: UIBarMetrics.Default
        )
    }

    // MARK: - Setters

    func setTooltipVisible(visible: Bool, animated: Bool = false, touchPoint: CGPoint = CGPointZero) {
        let adjustTooltipPosition: dispatch_block_t = {
            var originalTouchPoint = self.chartViewContainerView.convertPoint(touchPoint, fromCoordinateSpace: self.chartViewContainerView)
            var convertedTouchPoint = originalTouchPoint

            let minChartX = ceil(self.tooltipView.frame.size.width * 0.5)
            convertedTouchPoint.x = max(convertedTouchPoint.x, minChartX)

            let maxChartX = self.chartViewContainerView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5)
            convertedTouchPoint.x = min(convertedTouchPoint.x, maxChartX)

            self.tooltipView.frame = CGRectMake(
                convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5),
                CGRectGetMinY(self.chartViewContainerView.frame) + ceil(self.tooltipView.frame.height * 0.5),
                self.tooltipView.frame.size.width,
                self.tooltipView.frame.size.height
            )

            let minTipX = self.tooltipTipView.frame.size.width
            originalTouchPoint.x = max(originalTouchPoint.x, minTipX)

            let maxTipX = self.chartViewContainerView.frame.size.width - self.tooltipTipView.frame.size.width
            originalTouchPoint.x = min(originalTouchPoint.x, maxTipX)

            self.tooltipTipView.frame = CGRectMake(
                originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5),
                CGRectGetMaxY(self.tooltipView.frame),
                self.tooltipTipView.frame.size.width,
                self.tooltipTipView.frame.size.height
            )
        }

        let adjustTooltipVisibility: dispatch_block_t = {
            self.tooltipView.alpha = visible ? 1.0 : 0.0
            self.tooltipTipView.alpha = visible ? 1.0 : 0.0
        }

        if visible {
            adjustTooltipPosition()
        }

        if animated {
            UIView.animateWithDuration(0.25, animations: {
                adjustTooltipVisibility()
            }, completion: { finished in
                if !finished {
                    adjustTooltipPosition()
                }
            })
        } else {
            adjustTooltipVisibility()
        }
    }

}
