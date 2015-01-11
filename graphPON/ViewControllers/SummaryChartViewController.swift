import UIKit
import JBChartFramework
import Alamofire
import SwiftyJSON

class SummaryChartViewController: BaseLineChartViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, HddServiceListTableViewControllerDelegate, DisplayPacketLogsSelectTableViewControllerDelegate {

    private let mode: Mode = .Summary

    private var chartDataSegment: ChartDataSegment = .All
    private var chartDurationSegment: HdoInfo.Duration = .InThisMonth
    private var hddServiceCode: String = ""
    private var hdoInfos: [HdoInfo]? = []
    private var chartData: [[CGFloat]]? = []

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.mode.backgroundColor()
        self.navigationItem.title = self.mode.titleText()

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

        self.chartInformationView.hidden = true

        self.navigationItem.title = ""
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.reloadChartView(false)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationDidBecomeActiveNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { _ in
                self.promptLogin()
        })

        NSNotificationCenter.defaultCenter().addObserverForName(
            PacketInfoManager.LatestPacketLogsDidFetchNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { _ in
                self.reloadChartView(true)
        })

        switch OAuth2Client.sharedClient.state {
        case .UnAuthorized:
            self.promptLogin()
        default:
            break
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Actions

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HddServiceListFromSummaryChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let hddServiceListViewController = navigationController.topViewController as HddServiceListTableViewController
            hddServiceListViewController.delegate = self
            hddServiceListViewController.services = PacketInfoManager.sharedManager.hddServiceCodes()
        } else if segue.identifier == "DisplayPacketLogsSelectFromSummaryChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let displayPacketLogSelectViewController = navigationController.topViewController as DisplayPacketLogsSelectTableViewController
            displayPacketLogSelectViewController.delegate = self
        }
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            self.chartDurationSegment = .InThisMonth
        default:
            self.chartDurationSegment = .InLast30Days
        }
        self.reloadChartView(false)
    }

    func reloadChartView(animated: Bool) {
        self.reBuildChartData()

        if !self.loadingIndicatorView.hidden {
            self.loadingIndicatorView.stopAnimating()
        }

        if let hddServiceCode = PacketInfoManager.sharedManager.hddServiceCodes().first {
            self.navigationItem.title = "\(hddServiceCode) (\(self.chartDataSegment.text()))"
        }

        self.chartViewContainerView.chartView.maximumValue = self.chartData?.last?.last ?? 0

        if let footerView = self.chartViewContainerView.chartView.footerView as? LineChartFooterView {
            footerView.leftLabel.text = self.hdoInfos?.first?.packetLogs.first?.dateText()
            footerView.rightLabel.text = self.hdoInfos?.first?.packetLogs.last?.dateText()
            footerView.sectionCount = self.chartData?.first?.count ?? 0
            footerView.hidden = false
        }

        self.displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: animated)
    }

    func displayLatestTotalChartInformation() {
        let (label, date) = ("Total", self.hdoInfos?.first?.packetLogs.last?.dateText())

        if date == nil {
            self.chartInformationView.setHidden(true)
            self.informationValueLabelSeparatorView.alpha = 0.0
            self.valueLabel.alpha = 0.0
            return
        }

        if date != nil {
            self.chartInformationView.setTitleText("\(label) - \(String(date!))")
            self.chartInformationView.setHidden(false, animated: true)
        }
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

    func promptLogin() {
        switch OAuth2Client.sharedClient.state {
        case OAuth2Client.AuthorizationState.UnAuthorized:
            if let _ = self.presentedViewController as? PromptLoginController {
                break
            }
            return self.presentViewController(
                PromptLoginController.alertController(),
                animated: true,
                completion: nil
            )
        default:
            break
        }
    }

    // MARK: - Private methods

    func reBuildChartData() {
        let logManager = PacketInfoManager.sharedManager
        self.hdoInfos  = []
        self.chartData = []

        if find(logManager.hddServiceCodes(), self.hddServiceCode) == nil {
            self.hddServiceCode = logManager.hddServiceCodes().first ?? ""
        }

        self.hdoInfos = logManager.hddServiceForServiceCode(self.hddServiceCode)?.hdoInfos
        if self.hdoInfos == nil {
            return
        }

        for hdoInfo in self.hdoInfos! {
            hdoInfo.duration = self.chartDurationSegment
        }

        var totalSum = [CGFloat](count: self.hdoInfos!.first!.packetLogs.count, repeatedValue: 0.0)
        self.chartData = self.hdoInfos?.reduce([], combine: { (var _chartData, hdoInfo) -> [[CGFloat]] in
            var hdoServiceindex = 0
            let hdoPacketSum = hdoInfo.packetLogs.reduce([], combine: { (var _hdoPacketSum, packetLog) -> [CGFloat] in
                var lastPacketAmount = _hdoPacketSum.last ?? 0.0
                switch self.chartDataSegment.rawValue {
                case 0:
                    lastPacketAmount += CGFloat(packetLog.withCoupon + packetLog.withoutCoupon)
                case 1:
                    lastPacketAmount += CGFloat(packetLog.withCoupon)
                case 2:
                    lastPacketAmount += CGFloat(packetLog.withoutCoupon)
                default:
                    break
                }
                totalSum[hdoServiceindex++] += lastPacketAmount
                _hdoPacketSum.append(lastPacketAmount)
                return _hdoPacketSum
            })
            _chartData.append(hdoPacketSum)
            return _chartData
        })
        self.chartData?.append(totalSum)
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
        let displayTooltip = tcolVert == .Compact || (tcolVert == .Regular && tcolHorz == .Regular)

        let dateText = self.hdoInfos?.first?.packetLogs[Int(horizontalIndex)].dateText() ?? ""
        if displayTooltip {
            self.setTooltipVisible(true, animated: false, touchPoint: touchPoint)
            self.tooltipView.setText(dateText)
        }

        var label = "Total"
        if Int(lineIndex) < self.hdoInfos?.count {
            label = self.hdoInfos?[Int(lineIndex)].hdoServiceCode ?? ""
        }
        self.chartInformationView.setTitleText("\(label) - \(dateText)")
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
        self.setTooltipVisible(false, animated: true)

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
        self.navigationItem.title = PacketInfoManager.sharedManager.hddServiceCodes()[row]
    }

    // MARK: - DisplayPacketLogsSelectTableViewControllerDelegate

    func displayPacketLogSegmentDidSelected(segment: Int) {
        self.chartDataSegment = ChartDataSegment(rawValue: segment)!
        self.reloadChartView(true)
    }

}
