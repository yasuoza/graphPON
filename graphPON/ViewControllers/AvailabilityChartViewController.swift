import UIKit
import JBChartFramework
import XYDoughnutChart

class AvailabilityChartViewController: BaseChartViewController, XYDoughnutChartDelegate, XYDoughnutChartDataSource, HddServiceListTableViewControllerDelegate {

    private let mode: Mode = .Availability

    @IBOutlet private var ratioChartContainerView: RatioChartContainerView!
    @IBOutlet private var usedLabel: UILabel!
    @IBOutlet private var usedPercentageLabel: UILabel!

    private var hddService: HddService? {
        didSet {
            self.serviceCode = hddService?.hddServiceCode
        }
    }
    private var slices: [CGFloat]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chartDataFilteringSegment = .On

        self.view.backgroundColor = self.mode.backgroundColor()

        self.ratioChartContainerView.chartView.showLabel = false
        self.ratioChartContainerView.chartView.dataSource = self
        self.ratioChartContainerView.chartView.delegate = self
        self.ratioChartContainerView.chartView.radiusOffset = 0.8;

        self.chartInformationView.setHidden(true, animated: true)

        self.reBuildChartData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.reloadChartView(animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if iOS3_5InchPortraitOrientation() {
            self.usedLabel.font = UIFont(name: GlobalValueFontFamily, size: 35.0)
            self.usedPercentageLabel.font = UIFont(name: GlobalValueFontFamily, size: 50.0)
        }
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
        if segue.identifier == "HddServiceListFromRatioChartSegue" {
            let navigationController = segue.destinationViewController as UINavigationController
            let hddServiceListViewController = navigationController.topViewController as HddServiceListTableViewController
            hddServiceListViewController.delegate = self
            hddServiceListViewController.selectedService = self.serviceCode ?? ""
        }
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDurationSegment = HdoService.Duration(rawValue: segmentedControl.selectedSegmentIndex)!
        self.reBuildChartData()
        self.reloadChartView(true)
    }

    func reloadChartView(animated: Bool) {
        if let hddService = self.hddService {
            self.navigationItem.title = "\(hddService.nickName)"
        }

        self.ratioChartContainerView.chartView.reloadData(animated)
        self.displayLatestTotalChartInformation()
    }

    func displayLatestTotalChartInformation() {
        if let slices = self.slices {
            if slices.first == nil {
                return
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd"
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            let today = dateFormatter.stringFromDate(NSDate())
            let endOfThisMonth = dateFormatter.stringFromDate(NSDate().endDateOfMonth()!)
            self.chartInformationView.setTitleText(
                String(format: NSLocalizedString("Available in %@-%@", comment: "Chart information title text in available chart"),
                    today, endOfThisMonth)
            )
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

    // MARK: - Private methods

    func reBuildChartData() {
        let logManager = PacketInfoManager.sharedManager

        if let hddService = logManager.hddServiceForServiceCode(self.serviceCode)
            ?? logManager.hddServices.first {
            self.hddService = hddService
        } else {
            return
        }

        let packetSum = self.hddService?.hdoServices?.map { hdoInfo -> CGFloat in
            hdoInfo
                .summarizeServiceUsageInDuration(.InThisMonth, couponSwitch: .On)
                .reduce(0.0, combine: +)
        }

        if let usedPackets = packetSum {
            let used = usedPackets.reduce(0, combine:+)
            let available = CGFloat(self.hddService?.availableCouponVolume() ?? 0)
            self.slices = [used, available];
        }
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
        self.reBuildChartData()
        if self.traitCollection.horizontalSizeClass == .Regular {
            self.reloadChartView(true)
        }
    }

}
