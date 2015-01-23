import UIKit
import JBChartFramework
import XYDoughnutChart

class RatioChartViewController: BaseChartViewController, XYDoughnutChartDelegate, XYDoughnutChartDataSource, HddServiceListTableViewControllerDelegate, DisplayPacketLogsSelectTableViewControllerDelegate {

    private let mode: Mode = .Ratio

    @IBOutlet var ratioChartContainerView: RatioChartContainerView!

    private var hddService: HddService? {
        didSet {
            self.serviceCode = hddService?.hddServiceCode
        }
    }
    private var slices: [CGFloat]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = self.mode.backgroundColor()

        self.ratioChartContainerView.chartView.showLabel = false
        self.ratioChartContainerView.chartView.dataSource = self
        self.ratioChartContainerView.chartView.delegate = self

        self.chartInformationView.setHidden(true, animated: true)
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
        if segue.identifier == "HddServiceListFromRatioChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let hddServiceListViewController = navigationController.topViewController as HddServiceListTableViewController
            hddServiceListViewController.delegate = self
            hddServiceListViewController.selectedService = self.serviceCode ?? ""
        } else if segue.identifier == "DisplayPacketLogsSelectFromRatioChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let displayPacketLogSelectViewController = navigationController.topViewController as DisplayPacketLogsSelectTableViewController
            displayPacketLogSelectViewController.delegate = self
        }
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDurationSegment = HdoService.Duration(rawValue: segmentedControl.selectedSegmentIndex)!
        self.reloadChartView(true)
    }

    func reloadChartView(animated: Bool) {
        self.reBuildChartData()

        if let hddService = self.hddService {
            self.navigationItem.title = "\(hddService.nickName) (\(self.chartDataFilteringSegment.text()))"
        }

        self.ratioChartContainerView.chartView.reloadData(animated)
        self.displayLatestTotalChartInformation()
    }

    func displayLatestTotalChartInformation() {
        if let slices = self.slices {
            if slices.count == 0 {
                return
            }
            let max = maxElement(slices)
            let maxIndex = find(slices, max)
            if maxIndex == nil {
                return
            }
            if let hdoService = self.hddService?.hdoServices?[maxIndex!] {
                self.chartInformationView.setTitleText("Proportion - \(hdoService.nickName)")
                self.chartInformationView.setHidden(false, animated: true)
                UIView.animateWithDuration(
                    NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
                    delay: 0.0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: {
                        self.informationValueLabelSeparatorView.alpha = 1.0
                        let valueText = NSString(format: "%.01f", Float(max ?? 0.0))
                        self.valueLabel.text = "\(valueText)%"
                        self.valueLabel.alpha = 1.0
                    },
                    completion: nil
                )
            }
        }
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
        self.slices = []

        if let hddService = logManager.hddServiceForServiceCode(self.serviceCode ?? "") ?? logManager.hddServices.first {
            self.hddService = hddService
        } else {
            return
        }

        for hdoInfo in self.hddService!.hdoServices! {
            hdoInfo.duration = self.chartDurationSegment
        }

        let packetSum = self.hddService?.hdoServices?.map { hdoInfo -> CGFloat in
            return hdoInfo.packetLogs.reduce(0.0, combine: { (hdoPacketSum, packetLog) -> CGFloat in
                switch self.chartDataFilteringSegment {
                case .All:
                    return hdoPacketSum + CGFloat(packetLog.withCoupon + packetLog.withoutCoupon)
                case .WithCoupon:
                    return hdoPacketSum + CGFloat(packetLog.withCoupon)
                case .WithoutCoupon:
                    return hdoPacketSum + CGFloat(packetLog.withoutCoupon)
                }
            })
        } ?? []

        var total = packetSum.reduce(0, combine:+)
        total = total == 0 ? 1 : total
        self.slices = packetSum.map { $0 / total * 100 }
    }

    // MARK: - XYDoughnutChartDelegate

    func doughnutChart(doughnutChart: XYDoughnutChart!, didSelectSliceAtIndexPath indexPath: NSIndexPath) {
        if let hdoService = self.hddService?.hdoServices?[indexPath.slice] {
            self.chartInformationView.setTitleText("Proportion - \(hdoService.nickName)")
            self.chartInformationView.setHidden(false, animated: true)
        }

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                let valueText = NSString(format: "%.01f", Float(self.slices?[indexPath.slice] ?? 0.0))
                self.valueLabel.text = "\(valueText)%"
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, didDeselectSliceAtIndexPath indexPath: NSIndexPath) {
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

    func doughnutChart(doughnutChart: XYDoughnutChart!, colorForSliceAtIndexPath indexPath: NSIndexPath!) -> UIColor! {
        if let slices = self.slices {
            var max = maxElement(slices)
            max = max == 0 ? 1.0 : max
            let alpha = slices[indexPath.slice] / max
            return UIColor.whiteColor().colorWithAlphaComponent(alpha)
        }
        return UIColor.clearColor()
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, selectedStrokeWidthForSliceAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 2.0
    }

    // MARK: - XYDoughnutChartDataSource

    func numberOfSlicesInDoughnutChart(doughnutChart: XYDoughnutChart!) -> Int {
        return slices?.count ?? 0;
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, valueForSliceAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(self.slices?[indexPath.slice] ?? 0);
    }

    // MARK: - HddServiceListTableViewControllerDelegate

    func serviceDidSelectedSection(section: Int, row: Int) {
        self.hddService = PacketInfoManager.sharedManager.hddServices[row]
        if self.traitCollection.horizontalSizeClass == .Regular {
            self.reloadChartView(true)
        }
    }

    // MARK: - DisplayPacketLogsSelectTableViewControllerDelegate

    func displayPacketLogSegmentDidSelected(segment: Int) {
        self.chartDataFilteringSegment = ChartDataFilteringSegment(rawValue: segment)!
        if self.traitCollection.horizontalSizeClass == .Regular {
            self.reloadChartView(true)
        }
    }

    // MARK: - UIStateRestoration

    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(self.serviceCode, forKey: "hddServiceCode")
        coder.encodeInteger(self.chartDurationSegment.rawValue, forKey: "hddChartDurationSegment")
        coder.encodeInteger(self.chartDataFilteringSegment.rawValue, forKey: "hddChartFilteringSegment")
        super.encodeRestorableStateWithCoder(coder)
    }

    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        if let hddServiceCode = coder.decodeObjectForKey("hddServiceCode") as? String {
            self.serviceCode = hddServiceCode
        }
        self.chartDurationSegment = HdoService.Duration(rawValue: Int(coder.decodeIntForKey("hddChartDurationSegment")))!
        self.chartDurationSegmentControl.selectedSegmentIndex = self.chartDurationSegment.rawValue
        self.chartDataFilteringSegment = ChartDataFilteringSegment(rawValue: Int(coder.decodeIntForKey("hddChartFilteringSegment")))!
        super.decodeRestorableStateWithCoder(coder)
    }

}
