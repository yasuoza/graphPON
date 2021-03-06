import UIKit
import GraphPONDataKit
import JBChartFramework

class DailyChartViewController: BaseChartViewController, JBBarChartViewDelegate, JBBarChartViewDataSource, HddServiceListTableViewControllerDelegate, DisplayPacketLogsSelectTableViewControllerDelegate {

    @IBOutlet weak var chartViewContainerView: ChartViewContainerView!

    let mode: Mode = .Daily

    private var chartData: [CGFloat]?
    private var chartHorizontalData: [String]?
    private var hdoService: HdoService? {
        didSet {
            self.serviceCode = hdoService?.hdoServiceCode
        }
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.mode.backgroundColor()

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

        self.chartInformationView.setHidden(true, animated: false)

        if self.serviceCode == nil {
            if let hdoService = PacketInfoManager.sharedManager.hddServices.first?.hdoServices?.first {
                self.hdoService = hdoService
            }
        }

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
        if segue.identifier == "HddServiceListFromDailyChartSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let hddServiceListViewController = navigationController.topViewController as! HddServiceListTableViewController
            hddServiceListViewController.delegate = self
            hddServiceListViewController.mode = .Daily
            hddServiceListViewController.selectedService = self.hdoService?.number ?? ""
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
        if let hdoService = self.hdoService {
            self.navigationItem.title = "\(hdoService.nickName) (\(self.chartDataFilteringSegment.text()))"
        }

        if let chartData = self.chartData where chartData.count > 0 {
            self.chartViewContainerView.chartView.minimumValue = 0
            self.chartViewContainerView.chartView.maximumValue = maxElement(chartData)
        }

        if let footerView = self.chartViewContainerView.chartView.footerView as? LineChartFooterView {
            footerView.leftLabel.text = self.hdoService?.packetLogs.first?.dateText()
            footerView.rightLabel.text = self.hdoService?.packetLogs.last?.dateText()
            footerView.sectionCount = self.chartData?.count ?? 0
            footerView.hidden = footerView.sectionCount == 0
        }
        self.displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: animated)
    }

    func displayLatestTotalChartInformation() {
        if let packetLog = self.hdoService?.packetLogs.last {
            self.chartInformationView.setTitleText(
                String(format: NSLocalizedString("Used in %@", comment: "Chart information title text in daily chart"),
                    packetLog.dateText())
            )
            self.chartInformationView.setHidden(false, animated: true)
        } else {
            self.chartInformationView.setHidden(true, animated: false)
            self.informationValueLabelSeparatorView.alpha = 0.0
            self.valueLabel.alpha = 0.0
            return
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
        if let hdoService = PacketInfoManager.sharedManager.hdoServiceForServiceCode(self.serviceCode)
            ?? PacketInfoManager.sharedManager.hddServices.first?.hdoServices?.first {
            self.hdoService = hdoService
        } else {
            return
        }

        self.chartData = self.hdoService?.summarizeServiceUsageInDuration(
            self.chartDurationSegment,
            couponSwitch: self.chartDataFilteringSegment
        )

        self.chartHorizontalData = self.hdoService?.packetLogs.map { $0.dateText() }
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
        let dateText = self.chartHorizontalData?[Int(index)] ?? ""
        self.chartInformationView.setTitleText(
            String(format: NSLocalizedString("Used in %@", comment: "Chart information title text in daily chart"),
                dateText)
        )
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
        self.hdoService = PacketInfoManager.sharedManager.hddServices[section].hdoServices?[row]
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
