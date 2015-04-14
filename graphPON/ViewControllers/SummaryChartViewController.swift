import UIKit
import JBChartFramework
import Alamofire
import SwiftyJSON

class SummaryChartViewController: BaseChartViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, HddServiceListTableViewControllerDelegate, DisplayPacketLogsSelectTableViewControllerDelegate {

    @IBOutlet private weak var chartViewContainerView: ChartViewContainerView!

    private let mode: Mode = .Summary

    private var hddService: HddService? {
        didSet {
            self.serviceCode = hddService?.hddServiceCode
        }
    }
    private var chartData: [[CGFloat]]? = []
    private var chartHorizontalData: [String]?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.mode.backgroundColor()

        self.chartViewContainerView.chartView.delegate = self
        self.chartViewContainerView.chartView.dataSource = self

        self.chartViewContainerView.chartView.footerPadding = kJBAreaChartViewControllerChartFooterPadding
        self.chartViewContainerView.chartView.backgroundColor = self.mode.backgroundColor()

        let footerView = LineChartFooterView(
            frame: CGRectMake(
                self.chartViewContainerView.chartView.frame.origin.x,
                ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5),
                self.chartViewContainerView.chartView.bounds.width,
                kJBLineChartViewControllerChartFooterHeight + kJBLineChartViewControllerChartPadding
            )
        )
        footerView.backgroundColor = UIColor.clearColor()
        footerView.leftLabel.textColor = UIColor.whiteColor()
        footerView.rightLabel.textColor = UIColor.whiteColor()
        footerView.hidden = true
        self.chartViewContainerView.chartView.footerView = footerView

        self.chartInformationView.setHidden(true, animated: false)

        self.reBuildChartData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.reloadChartView(animated)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().addObserverForName(
            PacketInfoManager.LatestPacketLogsDidFetchNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { _ in
                self.reBuildChartData()
                self.reloadChartView(true)
        })
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Actions

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HddServiceListFromSummaryChartSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let hddServiceListViewController = navigationController.topViewController as! HddServiceListTableViewController
            hddServiceListViewController.delegate = self
            hddServiceListViewController.selectedService = self.serviceCode ?? ""
        } else if segue.identifier == "DisplayPacketLogsSelectFromSummaryChartSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let displayPacketLogSelectViewController = navigationController.topViewController as! DisplayPacketLogsSelectTableViewController
            displayPacketLogSelectViewController.delegate = self
            displayPacketLogSelectViewController.selectedFilteringSegment = self.chartDataFilteringSegment
        }
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDurationSegment = HdoService.Duration(rawValue: segmentedControl.selectedSegmentIndex)!
        self.reBuildChartData()
        self.reloadChartView(false)
    }

    func reloadChartView(animated: Bool) {
        if !self.loadingIndicatorView.hidden {
            self.loadingIndicatorView.stopAnimating()
        }

        if let hddService = self.hddService {
            self.navigationItem.title = "\(hddService.nickName) (\(self.chartDataFilteringSegment.text()))"
        }

        self.chartViewContainerView.chartView.maximumValue = self.chartData?.last?.last ?? 0

        if let footerView = self.chartViewContainerView.chartView.footerView as? LineChartFooterView {
            footerView.leftLabel.text = self.hddService?.hdoServices?.first?.packetLogs.first?.dateText()
            footerView.rightLabel.text = self.hddService?.hdoServices?.first?.packetLogs.last?.dateText()
            footerView.sectionCount = self.chartData?.first?.count ?? 0
            footerView.hidden = footerView.sectionCount == 0
        }

        self.displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: animated)
    }

    func displayLatestTotalChartInformation() {
        let (label, dateText) = (
            NSLocalizedString("Total", comment: "Total"),
            self.hddService?.hdoServices?.first?.packetLogs.last?.dateText()
        )

        if dateText == nil {
            self.chartInformationView.setHidden(true, animated: false)
            self.informationValueLabelSeparatorView.alpha = 0.0
            self.valueLabel.alpha = 0.0
            return
        }

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        let startDateOfThisMonth: String
        switch self.chartDurationSegment {
        case .InThisMonth:
            startDateOfThisMonth = dateFormatter.stringFromDate(NSDate().startDateOfMonth()!)
        case .InLast30Days:
            startDateOfThisMonth = self.hddService?.hdoServices?.first?.packetLogs.first?.dateText() ?? ""
        }

        self.chartInformationView.setTitleText(
            String(format: NSLocalizedString("%@ in %@-%@", comment: "Chart information title text in summary chart"),
                label, startDateOfThisMonth, dateText!)
        )
        self.chartInformationView.setHidden(false, animated: true)
        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                self.valueLabel.text = PacketLog.stringForValue(self.chartData?.last?.last!)
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )

    }

    // MARK: - Private methods

    func reBuildChartData() {
        let logManager = PacketInfoManager.sharedManager
        self.chartData = []

        if let hddService = logManager.hddServiceForServiceCode(self.serviceCode) ?? logManager.hddServices.first {
            self.hddService = hddService
        } else {
            return
        }

        self.chartData = self.hddService?.summarizeServiceUsageInDuration(
            self.chartDurationSegment,
            couponSwitch: self.chartDataFilteringSegment
        )

        self.chartHorizontalData = self.hddService?.hdoServices?.first?.packetLogs.map { packetLog in
            return packetLog.dateText()
        }
    }

    // MARK: - JBLineChartViewDataSource

    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return UInt(self.chartData?.count ?? 0)
    }

    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(self.chartData?.first?.count ?? 0)
    }

    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }

    // MARK: - JBLineChartViewDelegate

    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return self.chartData?[Int(lineIndex)][Int(horizontalIndex)] ?? 0.0
    }

    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt, touchPoint: CGPoint) {
        let tcolVert = self.traitCollection.verticalSizeClass
        let tcolHorz = self.traitCollection.horizontalSizeClass
        let dateText = self.chartHorizontalData?[Int(horizontalIndex)] ?? ""

        var label = NSLocalizedString("Total", comment: "Total")
        if Int(lineIndex) < self.hddService?.hdoServices?.count {
            label = self.hddService?.hdoServices?[Int(lineIndex)].nickName ?? ""
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        let startDateOfThisMonth: String
        switch self.chartDurationSegment {
        case .InThisMonth:
            startDateOfThisMonth = dateFormatter.stringFromDate(NSDate().startDateOfMonth()!)
        case .InLast30Days:
            startDateOfThisMonth = self.chartHorizontalData?.first ?? ""
        }

        self.chartInformationView.setTitleText(
            String(format: NSLocalizedString("%@ in %@-%@", comment: "Chart information title text in summary chart"),
                label, startDateOfThisMonth, dateText)
        )
        self.chartInformationView.setHidden(false, animated: true)

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                self.valueLabel.text = PacketLog.stringForValue(self.chartData?[Int(lineIndex)][Int(horizontalIndex)])
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )
    }

    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        self.chartInformationView.setHidden(true, animated: true)

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 0.0
                self.valueLabel.alpha = 0.0
            },
            completion: { finish in
                if finish {
                    self.displayLatestTotalChartInformation()
                }
            }
        )
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

    func serviceDidSelectedSection(section: Int, row: Int) {
        self.hddService = PacketInfoManager.sharedManager.hddServices[row]
        self.reBuildChartData()
        if self.traitCollection.horizontalSizeClass == .Regular {
            self.reloadChartView(true)
        }
    }

    // MARK: - DisplayPacketLogsSelectTableViewControllerDelegate

    func displayPacketLogSegmentDidSelected(segment: Int) {
        self.chartDataFilteringSegment = Coupon.Switch(rawValue: segment)!
        self.reBuildChartData()
        if self.traitCollection.horizontalSizeClass == .Regular {
            self.reloadChartView(true)
        }
    }

}
