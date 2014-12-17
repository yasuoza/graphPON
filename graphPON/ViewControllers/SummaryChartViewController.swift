import UIKit

class SummaryChartViewController: BaseLineChartViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, HddServiceListTableViewControllerDelegate {

    @IBOutlet weak var chartInformationView: ChartInformationView!
    @IBOutlet weak var informationValueLabelSeparatorView: UIView!
    @IBOutlet weak var valueLabel: UILabel!

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

    private let mode: Mode = .Summary
    private let chartLabels = ["00000000000", "11111111111", "22222222222", "Total"]

    private var chartDataSegment: ChartDataSegment = .All
    private var chartData: Array<Array<CGFloat>>!
    private var horizontalSymbols: [NSString]!

    var amounts = [
        [21, 11, 32, 14, 67, 11, 66, 45, 100, 44, 31, 38, 53, 70, 2, 1, 33, 52, 34, 11, 3],
        [7, 3, 12, 11, 4, 37, 6, 33, 1, 18, 1, 1, 1, 12, 1, 1, 1, 15, 1, 1, 1],
        [1, 1, 1, 65, 1, 22, 18, 23, 12, 13, 2, 14, 2, 29, 8, 1, 7, 5, 1, 4, 20]
    ]

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initFakeData()
        self.chartViewContainerView.chartView.maximumValue = self.chartData.last!.last!

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

        self.presentTotalChartInformation()
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HddServiceListFromSummaryChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let hddServiceListViewController = navigationController.topViewController as HddServiceListTableViewController
            hddServiceListViewController.delegate = self
        }
    }

    // MARK: - Actions
    
    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDataSegment = ChartDataSegment(rawValue: segmentedControl.selectedSegmentIndex)!
        initFakeData()
        presentTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
    }

    func presentTotalChartInformation() {
        let (label, date) = (self.chartLabels.last?, self.horizontalSymbols.last?)
        if label != nil && date != nil {
            self.chartInformationView.setTitleText("\(String(label!)) - \(String(date!))")
            self.chartInformationView.setHidden(false, animated: true)
        }
        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.informationValueLabelSeparatorView.alpha = 1.0
            var (value, unit) = (self.chartData.last?.last, "MB")
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
        var amountSummation = [CGFloat](count: amounts.first!.count, repeatedValue: 0.0)
        let multipler = self.chartDataSegment.rawValue == 0 ? 1.0 : CGFloat(2.0 / 3.0) / CGFloat(self.chartDataSegment.rawValue)
        self.chartData = self.amounts.map { packets -> [CGFloat] in
            var sum = CGFloat(0.0)
            var index = 0
            return packets.map { packet -> CGFloat in
                sum += CGFloat(packet) * multipler
                amountSummation[index++] += sum
                return sum
            }
        }
        self.chartData.append(amountSummation)

        // 今月の日付を表示
        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        var comps = calendar.components(
            (NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay), fromDate: today
        )
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")

        horizontalSymbols = (1...largestLineData().count).map {
            comps.day = $0
            let date = calendar.dateFromComponents(comps)!
            return dateFormatter.stringFromDate(date)
        }
    }

    func largestLineData() -> NSArray {
        return self.chartData[0]
    }

    // MARK: - JBLineChartViewDataSource

    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return UInt(self.chartData.count)
    }

    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(largestLineData().count)
    }

    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }

    // MARK: - JBLineChartViewDelegate

    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return self.chartData[Int(lineIndex)][Int(horizontalIndex)]
    }

    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt, touchPoint: CGPoint) {

        let displayTooltip = self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact
                                || (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular
                                        && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular)
        if displayTooltip {
            self.setTooltipVisible(true, animated: false, touchPoint: touchPoint)
            self.tooltipView.setText(horizontalSymbols[Int(horizontalIndex)])
        }

        self.chartInformationView.setTitleText("\(self.chartLabels[Int(lineIndex)]) - \(horizontalSymbols[Int(horizontalIndex)])")
        self.chartInformationView.setHidden(false, animated: true)

        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.informationValueLabelSeparatorView.alpha = 1.0
            var (value, unit) = (self.chartData[Int(lineIndex)][Int(horizontalIndex)], "MB")
            if value >= 100_0.0 {
                (value, unit) =  (value / 100_0.0, "GB")
            }
            let valueText = NSString(format: "%.01f", Float(value))
            self.valueLabel.text = "\(valueText)\(unit)"
            self.valueLabel.alpha = 1.0
        }, completion: nil)
    }

    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        self.setTooltipVisible(false, animated: true)

        self.chartInformationView.setHidden(true, animated: true)

        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.informationValueLabelSeparatorView.alpha = 0.0
            self.valueLabel.alpha = 0.0
        }, completion: { [unowned self] finish in
            if finish {
                self.presentTotalChartInformation()
            }
        })

    }

    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.clearColor()
    }

    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(white: 1.0, alpha: 0.5)
    }

    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.clearColor()
    }

    func lineChartView(lineChartView: JBLineChartView!, selectionFillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(white: 1.0, alpha: 1.0)
    }

    func lineChartView(lineChartView: JBLineChartView!, verticalSelectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(red:0.392, green:0.392, blue:0.559, alpha:1.0)
    }

    // MARK: - HddServiceListTableViewControllerDelegate

    func hddServiceDidSelected(hddServiceString: String) {
        self.navigationItem.title = "hddservice: \(hddServiceString)"

        func randomly(a: Int, b: Int) -> Bool {
            return arc4random() % 2 == 0
        }

        self.amounts = (0...2).map { sorted(self.amounts[$0], randomly) }
        initFakeData()
        self.chartViewContainerView.reloadChartData()
    }

}
