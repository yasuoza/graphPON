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

        if let hddServiceCode = self.serviceCode {
            self.navigationItem.title = "\(hddServiceCode) (\(self.chartDataFilteringSegment.text()))"
        }

        self.ratioChartContainerView.chartView.reloadData(animated)
        self.displayLatestTotalChartInformation()
    }

    func displayLatestTotalChartInformation() {
        if let hdoService = self.hddService?.hdoServices?.last? {
            self.chartInformationView.setTitleText("Proportion - \(hdoService.number)")
            self.chartInformationView.setHidden(false, animated: true)

            UIView.animateWithDuration(
                NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
                delay: 0.0,
                options: UIViewAnimationOptions.BeginFromCurrentState,
                animations: {
                    self.informationValueLabelSeparatorView.alpha = 1.0
                    let valueText = NSString(format: "%.01f", Float(self.slices?.last ?? 0.0))
                    self.valueLabel.text = "\(valueText)%"
                    self.valueLabel.alpha = 1.0
                },
                completion: nil
            )
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
        self.hddService = nil
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

    func doughnutChart(doughnutChart: XYDoughnutChart!, didSelectSliceAtIndex index: UInt) {
        if let hdoService = self.hddService?.hdoServices?[Int(index)] {
            self.chartInformationView.setTitleText("Proportion - \(hdoService.number)")
            self.chartInformationView.setHidden(false, animated: true)
        }

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                let valueText = NSString(format: "%.01f", Float(self.slices?[Int(index)] ?? 0.0))
                self.valueLabel.text = "\(valueText)%"
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, didDeselectSliceAtIndex index: UInt) {
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

    // MARK: - XYDoughnutChartDataSource

    func numberOfSlicesInDoughnutChart(pieChart: XYDoughnutChart!) -> UInt {
        return UInt(slices?.count ?? 0);
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, valueForSliceAtIndex index: UInt) -> CGFloat {
        return CGFloat(self.slices?[Int(index)] ?? 0);
    }

    // MARK: - HddServiceListTableViewControllerDelegate

    func serviceDidSelectedSection(section: Int, row: Int) {
        self.hddService = PacketInfoManager.sharedManager.hddServices[row]
    }

    // MARK: - DisplayPacketLogsSelectTableViewControllerDelegate

    func displayPacketLogSegmentDidSelected(segment: Int) {
        self.chartDataFilteringSegment = ChartDataFilteringSegment(rawValue: segment)!
        self.reloadChartView(true)
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
