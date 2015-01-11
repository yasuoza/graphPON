import UIKit
import JBChartFramework

class DailyChartViewController: BaseLineChartViewController, JBBarChartViewDelegate, JBBarChartViewDataSource, HddServiceListTableViewControllerDelegate {

    let mode: Mode = .Daily

    private var chartDataSegment: ChartDataSegment = .All
    private var chartData: [CGFloat]? = []
    private var hdoInfo: HdoInfo?
    private var hdoServiceCode: String = ""

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

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
        footerView.leftLabel.textColor = UIColor.whiteColor()
        footerView.rightLabel.textColor = UIColor.whiteColor()
        self.chartViewContainerView.chartView.footerView = footerView

        self.chartInformationView.setHidden(true)

        self.navigationItem.title = ""

        if let hdoServiceCode = PacketInfoManager.sharedManager.hdoServiceCodes().first {
            self.hdoServiceCode = hdoServiceCode
            self.hdoInfo = PacketInfoManager.sharedManager.hdoServiceForServiceCode(hdoServiceCode)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.reloadChartView(false)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

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

    func reloadChartView(animated: Bool) {
        self.reBuildChartData()

        if let hdoServiceCode = self.hdoInfo?.hdoServiceCode {
            self.navigationItem.title = "\(hdoServiceCode) (\(self.chartDataSegment.text()))"
        }

        if let chartData = self.chartData {
            self.chartViewContainerView.chartView.maximumValue = maxElement(chartData)
        }

        if let footerView = self.chartViewContainerView.chartView.footerView as? LineChartFooterView {
            footerView.leftLabel.text = self.hdoInfo?.packetLogs.first?.dateText()
            footerView.rightLabel.text = self.hdoInfo?.packetLogs.last?.dateText()
            footerView.sectionCount = self.chartData?.count ?? 0
            footerView.hidden = false
        }
        self.displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: animated)
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "HddServiceListFromDailyChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let hddServiceListViewController = navigationController.topViewController as HddServiceListTableViewController
            hddServiceListViewController.delegate = self
            hddServiceListViewController.mode = .Daily
        }
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDataSegment = ChartDataSegment(rawValue: segmentedControl.selectedSegmentIndex)!
        reBuildChartData()
        displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
    }

    func displayLatestTotalChartInformation() {
        if let packetLog = self.hdoInfo?.packetLogs.last? {
            self.chartInformationView.setTitleText("Total - \(packetLog.dateText())")
            self.chartInformationView.setHidden(false, animated: true)
        }
        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                self.valueLabel.text = PacketLog.stringForValue(self.chartData?.last)
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )
    }

    // MARK: - Private methods

    func reBuildChartData() {
        self.hdoInfo = PacketInfoManager.sharedManager.hdoServiceForServiceCode(self.hdoServiceCode)
        self.chartData = self.hdoInfo?.packetLogs.map { packetLog -> CGFloat in
            return CGFloat(packetLog.withCoupon)
        }
    }

    // MARK: - JBLineChartViewDataSource

    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(self.chartData?.count ?? 0)
    }


    // MARK: - JBLineChartViewDelegate

    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return self.chartData?[Int(index)] ?? 0.0
    }

    func barChartView(barChartView: JBBarChartView!, didSelectBarAtIndex index: UInt, touchPoint: CGPoint) {
        let displayTooltip = self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact
            || (self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular
                && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Regular)

        let dateText = self.hdoInfo?.packetLogs[Int(index)].dateText() ?? ""
        if displayTooltip {
            self.setTooltipVisible(true, animated: false, touchPoint: touchPoint)
            self.tooltipView.setText(dateText)
        }

        self.chartInformationView.setTitleText("Total - \(dateText)")
        self.chartInformationView.setHidden(false, animated: true)

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.valueLabel.text = PacketLog.stringForValue(self.chartData?[Int(index)])
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )
    }

    func didDeselectBarChartView(barChartView: JBBarChartView!) {
        self.setTooltipVisible(false, animated: true)
        self.chartInformationView.setHidden(true, animated: true)

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.valueLabel.alpha = 0.0
            },
            completion: { [unowned self] finish in
                if finish {
                    self.displayLatestTotalChartInformation()
                }
            }
        )
    }

    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return UIColor.whiteColor()
    }

    func barSelectionColorForBarChartView(barChartView: JBBarChartView!) -> UIColor! {
        return UIColor(red:0.392, green:0.392, blue:0.559, alpha:1.0)
    }

    // MARK: - HddServiceListTableViewControllerDelegate

    func serviceDidSelectedSection(section: Int, row: Int) {
        self.hdoServiceCode = PacketInfoManager.sharedManager.hddServices[section].hdoInfos![row].hdoServiceCode
        self.hdoInfo = PacketInfoManager.sharedManager.hddServices[section].hdoInfos?[row]
        self.reloadChartView(true)
    }

}
