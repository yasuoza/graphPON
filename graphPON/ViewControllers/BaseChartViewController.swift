import UIKit

protocol ChartViewControllerProtocol {
    func chartView() -> JBChartView!
}

class BaseChartViewController: UIViewController, ChartViewControllerProtocol {

    var tooltipView: ChartTooltipView = ChartTooltipView()
    var tooltipTipView: ChartTooltipTipView = ChartTooltipTipView()

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.respondsToSelector(Selector("setEdgesForExtendedLayout:")) {
            self.edgesForExtendedLayout = UIRectEdge.Top
        }
        self.view.backgroundColor = UIColor.whiteColor()

        self.tooltipView.alpha = 1.0
        self.view.addSubview(self.tooltipView)

        self.tooltipTipView.alpha = 0.0
        self.view.addSubview(self.tooltipTipView)
    }

    // MARK: - Setters

    func setTooltipVisible(visible: Bool, animated: Bool = false, touchPoint: CGPoint = CGPointZero) {
        let chartView = self.chartView()

        if chartView == nil {
            return
        }

        let adjustTooltipPosition: dispatch_block_t = {
            var originalTouchPoint = self.view.convertPoint(touchPoint, fromCoordinateSpace: chartView)
            var convertedTouchPoint = originalTouchPoint
            if chartView != nil {
                let minChartX = chartView.frame.origin.x + ceil(self.tooltipView.frame.size.width * 0.5)
                convertedTouchPoint.x = max(convertedTouchPoint.x, minChartX)

                let maxChartX = chartView.frame.origin.x + chartView.frame.size.width - ceil(self.tooltipView.frame.size.width * 0.5)
                convertedTouchPoint.x = min(convertedTouchPoint.x, maxChartX)

                self.tooltipView.frame = CGRectMake(
                    convertedTouchPoint.x - ceil(self.tooltipView.frame.size.width * 0.5),
                    70,
                    self.tooltipView.frame.size.width,
                    self.tooltipView.frame.size.height
                )

                let minTipX = chartView.frame.origin.x + self.tooltipTipView.frame.size.width
                originalTouchPoint.x = max(originalTouchPoint.x, minTipX)

                let maxTipX = chartView.frame.origin.x + chartView.frame.size.width - self.tooltipTipView.frame.size.width
                originalTouchPoint.x = min(originalTouchPoint.x, maxTipX)

                self.tooltipTipView.frame = CGRectMake(
                    originalTouchPoint.x - ceil(self.tooltipTipView.frame.size.width * 0.5),
                    CGRectGetMaxY(self.tooltipView.frame),
                    self.tooltipTipView.frame.size.width,
                    self.tooltipTipView.frame.size.height
                )
            }
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

    // MARK: - Getters

    func chartView() -> JBChartView! {
        return JBChartView()
    }

}
