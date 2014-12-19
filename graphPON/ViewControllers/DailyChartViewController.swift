import UIKit

class DailyChartViewController: BaseLineChartViewController, JBBarChartViewDelegate, JBBarChartViewDataSource, HddServiceListTableViewControllerDelegate {

    let mode: Mode = .Daily

    private let kJBLineChartViewControllerChartPadding       = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeight        = CGFloat(250.0)
    private let kJBAreaChartViewControllerChartPadding       = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeaderHeight  = CGFloat(75.0)
    private let kJBAreaChartViewControllerChartHeaderPadding = CGFloat(20.0)
    private let kJBAreaChartViewControllerChartFooterHeight  = CGFloat(20.0)
    private let kJBAreaChartViewControllerChartFooterPadding = CGFloat(5.0)
    private let kJBAreaChartViewControllerChartLineWidth     = CGFloat(2.0)
    private let kJBAreaChartViewControllerMaxNumChartPoints  = CGFloat(12)
    private let kJBLineChartViewControllerChartFooterHeight  = CGFloat(20)

    private var chartDataSegment: ChartDataSegment = .All
    private var chartData: [CGFloat]!
    private var horizontalSymbols: [NSString]!

    var amounts = [29, 15, 45, 90, 72, 70, 90, 101, 113, 75, 34, 53, 56, 111, 11, 3, 41, 72, 36, 7, 8]

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initFakeData()
        self.chartViewContainerView.chartView.maximumValue = maxElement(self.chartData)

        self.view.backgroundColor = self.mode.backgroundColor()
        self.navigationItem.title = self.mode.titleText()

        self.chartViewContainerView.chartView.delegate = self
        self.chartViewContainerView.chartView.dataSource = self

        self.chartViewContainerView.chartView.headerPadding = kJBAreaChartViewControllerChartHeaderPadding
        self.chartViewContainerView.chartView.footerPadding = kJBAreaChartViewControllerChartFooterPadding
        self.chartViewContainerView.chartView.backgroundColor = self.mode.backgroundColor()

        let footerView = LineChartFooterView(frame: CGRectMake(
            self.chartViewContainerView.chartView.frame.origin.x,
            ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5),
            self.chartViewContainerView.chartView.bounds.width,
            kJBLineChartViewControllerChartFooterHeight + kJBLineChartViewControllerChartPadding
            ))
        footerView.backgroundColor = UIColor.clearColor()
        footerView.leftLabel.text = self.horizontalSymbols.first
        footerView.leftLabel.textColor = UIColor.whiteColor()
        footerView.rightLabel.text = self.horizontalSymbols.last
        footerView.rightLabel.textColor = UIColor.whiteColor()
        footerView.sectionCount = self.largestLineData().count
        self.chartViewContainerView.chartView.footerView = footerView

        self.chartInformationView.setHidden(true)

        self.navigationItem.title = "hddservice: service00"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.displayLatestTotalChartInformation()
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HddServiceListFromDailyChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let hddServiceListViewController = navigationController.topViewController as HddServiceListTableViewController
            hddServiceListViewController.delegate = self
        }
    }

    // MARK: - Actions

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDataSegment = ChartDataSegment(rawValue: segmentedControl.selectedSegmentIndex)!
        initFakeData()
        displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
    }

    func displayLatestTotalChartInformation() {
        if let date = self.horizontalSymbols.last? {
            self.chartInformationView.setTitleText("Total - \(String(date))")
            self.chartInformationView.setHidden(false, animated: true)
        }
        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.informationValueLabelSeparatorView.alpha = 1.0
            var (value, unit) = (self.chartData.last?, "MB")
            if value != nil && value >= 100_0.0 {
                (value, unit) =  (value! / 100_0.0, "GB")
            }
            let valueText = NSString(format: "%.01f", Float(value!))
            self.valueLabel.text = "\(valueText)\(unit)"
            self.valueLabel.alpha = 1.0
            }, completion: nil)
    }

    // MARK: - Private methods

    func initFakeData() {
        let multipler = self.chartDataSegment.rawValue == 0 ? 1.0 : CGFloat(2.0 / 3.0) / CGFloat(self.chartDataSegment.rawValue)
        chartData = amounts.map { CGFloat($0) * multipler }

        // 今月の日付を表示
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        var comps = calendar.components(
            (NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay), fromDate: today
        )
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")

        horizontalSymbols = (1...chartData.count).map {
            comps.day = $0
            let date = calendar.dateFromComponents(comps)!
            return dateFormatter.stringFromDate(date)
        }
    }

    func largestLineData() -> NSArray {
        return self.chartData
    }

    // MARK: - JBLineChartViewDataSource

    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(self.chartData.count)
    }


    // MARK: - JBLineChartViewDelegate

    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return self.chartData[Int(index)]
    }

    func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt, touchPoint: CGPoint) {
        let displayTooltip = self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact
            || (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular
                && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular)
        if displayTooltip {
            self.setTooltipVisible(true, animated: false, touchPoint: touchPoint)
            self.tooltipView.setText(horizontalSymbols[Int(index)])
        }

        self.chartInformationView.setTitleText("Total - \(horizontalSymbols[Int(index)])")
        self.chartInformationView.setHidden(false, animated: true)

        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            var value = self.chartData[Int(index)]
            var unit = "MB"
            if value >= 1000.0 {
                value /= 1000.0
                unit = "GB"
            }
            let valueText = NSString(format: "%.01f", Float(value))
            self.valueLabel.text = "\(valueText)\(unit)"
            self.valueLabel.alpha = 1.0
        }, completion: nil)
    }

    func didDeselectBarChartView(barChartView: JBBarChartView!) {
        self.setTooltipVisible(false, animated: true)
        self.chartInformationView.setHidden(true, animated: true)

        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.valueLabel.alpha = 0.0
        }, completion: { [unowned self] finish in
            if finish {
                self.displayLatestTotalChartInformation()
            }
        })
    }

    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return UIColor.whiteColor()
    }

    func barSelectionColorForBarChartView(barChartView: JBBarChartView!) -> UIColor! {
        return UIColor(red:0.392, green:0.392, blue:0.559, alpha:1.0)
    }

    // MARK: - HddServiceListTableViewControllerDelegate

    func hddServiceDidSelected(hddServiceString: String) {
        self.navigationItem.title = "hddservice: \(hddServiceString)"

        func randomly(a: Int, b: Int) -> Bool {
            return arc4random() % 2 == 0
        }

        self.amounts = sorted(self.amounts, randomly)
        initFakeData()
        self.chartViewContainerView.reloadChartData()
    }

}
