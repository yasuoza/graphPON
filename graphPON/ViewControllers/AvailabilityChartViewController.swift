import UIKit
import JBChartFramework
import XYDoughnutChart

class AvailabilityChartViewController: BaseChartViewController, XYDoughnutChartDelegate, XYDoughnutChartDataSource, HddServiceListTableViewControllerDelegate {

    private let mode: Mode = .Availability

    @IBOutlet var ratioChartContainerView: RatioChartContainerView!
    @IBOutlet var usedLabel: UILabel!
    @IBOutlet var usedPercentageLabel: UILabel!

    private var hddService: HddService? {
        didSet {
            self.serviceCode = hddService?.hddServiceCode
        }
    }
    private var slices: [CGFloat]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chartDataFilteringSegment = .WithCoupon

        self.view.backgroundColor = self.mode.backgroundColor()

        self.ratioChartContainerView.chartView.showLabel = false
        self.ratioChartContainerView.chartView.dataSource = self
        self.ratioChartContainerView.chartView.delegate = self
        self.ratioChartContainerView.chartView.radiusOffset = 0.8;

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
        }
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDurationSegment = HdoService.Duration(rawValue: segmentedControl.selectedSegmentIndex)!
        self.reloadChartView(true)
    }

    func reloadChartView(animated: Bool) {
        self.reBuildChartData()

        if let hddService = self.hddService {
            self.navigationItem.title = "\(hddService.nickName)"
        }

        self.ratioChartContainerView.chartView.reloadData(animated)
        self.displayLatestTotalChartInformation()
    }

    func displayLatestTotalChartInformation() {
        if let slices = self.slices {
            if slices.count == 0 {
                return
            }
            let maxIndex = find(slices, maxElement(slices))
            if maxIndex == nil {
                return
            }
            if let hdoService = self.hddService?.hdoServices?[maxIndex!] {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
                let today = dateFormatter.stringFromDate(NSDate())
                let endOfThisMonth = dateFormatter.stringFromDate(NSDate().endDateOfMonth()!)
                self.chartInformationView.setTitleText("Available in \(today)-\(endOfThisMonth)")
                self.chartInformationView.setHidden(false, animated: true)

                var totalAvailability = self.slices?.reduce(0, combine: +) ?? 1.0
                totalAvailability = totalAvailability != 0 ? totalAvailability : 1.0
                let usedPercentage = slices.first! / totalAvailability

                UIView.animateWithDuration(
                    NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
                    delay: 0.0,
                    options: UIViewAnimationOptions.BeginFromCurrentState,
                    animations: {
                        self.usedPercentageLabel.text = NSString(format: "%.01f%%", Float(usedPercentage * 100))
                        self.usedLabel.hidden = false
                        self.informationValueLabelSeparatorView.alpha = 1.0
                        self.valueLabel.text = PacketLog.stringForValue(slices.last)
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
                return hdoPacketSum + CGFloat(packetLog.withCoupon)
            })
            } ?? []

        let used = packetSum.reduce(0, combine:+)
        let available = CGFloat(self.hddService?.availableCouponVolume() ?? 0)
        self.slices = [used, available];
    }

    // MARK: - XYDoughnutChartDelegate

    func doughnutChart(doughnutChart: XYDoughnutChart!, willSelectSliceAtIndex indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, colorForSliceAtIndexPath indexPath: NSIndexPath!) -> UIColor! {
        if indexPath.slice == 0 {
            return UIColor.whiteColor()
        }

        return UIColor.whiteColor().colorWithAlphaComponent(0.5)
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
        self.chartDurationSegmentControl?.selectedSegmentIndex = self.chartDurationSegment.rawValue
        self.chartDataFilteringSegment = ChartDataFilteringSegment(rawValue: Int(coder.decodeIntForKey("hddChartFilteringSegment")))!
        super.decodeRestorableStateWithCoder(coder)
    }
    
}
