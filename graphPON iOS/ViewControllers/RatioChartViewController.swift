import UIKit
import GraphPONDataKit
import JBChartFramework
import XYDoughnutChart

class RatioChartViewController: BaseChartViewController, XYDoughnutChartDelegate, XYDoughnutChartDataSource, HddServiceListTableViewControllerDelegate, DisplayPacketLogsSelectTableViewControllerDelegate {

    private let mode: Mode = .Ratio

    @IBOutlet private var ratioChartContainerView: RatioChartContainerView!

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
        if segue.identifier == "HddServiceListFromRatioChartSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let hddServiceListViewController = navigationController.topViewController as! HddServiceListTableViewController
            hddServiceListViewController.delegate = self
            hddServiceListViewController.selectedService = self.serviceCode ?? ""
        } else if segue.identifier == "DisplayPacketLogsSelectFromRatioChartSegue" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let displayPacketLogSelectViewController = navigationController.topViewController as! DisplayPacketLogsSelectTableViewController
            displayPacketLogSelectViewController.delegate = self
            displayPacketLogSelectViewController.selectedFilteringSegment = self.chartDataFilteringSegment
        }
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDurationSegment = HdoService.Duration(rawValue: segmentedControl.selectedSegmentIndex)!
        self.reBuildChartData()
        self.reloadChartView(true)
    }

    func reloadChartView(animated: Bool) {
        if let hddService = self.hddService {
            self.navigationItem.title = "\(hddService.nickName) (\(self.chartDataFilteringSegment.text()))"
        }

        self.ratioChartContainerView.chartView.reloadData(animated)
        self.displayLatestTotalChartInformation()
    }

    func displayLatestTotalChartInformation() {
        if let slices = self.slices where slices.count > 0 {
            let maxValue = maxElement(slices)
            if let maxIndex = find(slices, maxValue),
                let hdoService = self.hddService?.hdoServices?[maxIndex] {
                    self.chartInformationView.setTitleText(
                        String(format: NSLocalizedString("Proportion of %@", comment: "Chart information title text in ratio chart"),
                            hdoService.nickName)
                    )
                    self.chartInformationView.setHidden(false, animated: true)
                    UIView.animateWithDuration(
                        NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
                        delay: 0.0,
                        options: UIViewAnimationOptions.BeginFromCurrentState,
                        animations: {
                            self.informationValueLabelSeparatorView.alpha = 1.0
                            let valueText = String(format: "%.01f", Float(maxValue))
                            self.valueLabel.text = "\(valueText)%"
                            self.valueLabel.alpha = 1.0
                        },
                        completion: nil
                    )
            }
        }
    }

    // MARK: - Private methods

    func reBuildChartData() {
        let logManager = PacketInfoManager.sharedManager
        self.slices = []

        if let hddService = logManager.hddServiceForServiceCode(self.serviceCode) ?? logManager.hddServices.first {
            self.hddService = hddService
        } else {
            return
        }

        let packetSum = self.hddService?.hdoServices?.map { hdoInfo -> CGFloat in
            return hdoInfo.summarizeServiceUsageInDuration(
                self.chartDurationSegment,
                couponSwitch: self.chartDataFilteringSegment
                ).reduce(0.0, combine: +)
            } ?? []

        var total = packetSum.reduce(0, combine:+)
        total = total == 0 ? 1 : total
        self.slices = packetSum.map { $0 / total * 100 }
    }

    // MARK: - XYDoughnutChartDelegate

    func doughnutChart(doughnutChart: XYDoughnutChart, didSelectSliceAtIndexPath indexPath: NSIndexPath) {
        if let hdoService = self.hddService?.hdoServices?[indexPath.slice] {
            self.chartInformationView.setTitleText(
                String(format: NSLocalizedString("Proportion of %@", comment: "Chart information title text in ratio chart"),
                    hdoService.nickName)
            )
            self.chartInformationView.setHidden(false, animated: true)
        }

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                let valueText = String(format: "%.01f", Float(self.slices?[indexPath.slice] ?? 0.0))
                self.valueLabel.text = "\(valueText)%"
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )
    }

    func doughnutChart(doughnutChart: XYDoughnutChart, didDeselectSliceAtIndexPath indexPath: NSIndexPath) {
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

    func doughnutChart(doughnutChart: XYDoughnutChart, colorForSliceAtIndexPath indexPath: NSIndexPath) -> UIColor {
        if let slices = self.slices where slices.count > 0 {
            var max = maxElement(slices)
            max = max == 0 ? 1.0 : max
            let alpha = slices[indexPath.slice] / max
            return UIColor.whiteColor().colorWithAlphaComponent(alpha)
        }
        return UIColor.clearColor()
    }

    func doughnutChart(doughnutChart: XYDoughnutChart, selectedStrokeWidthForSliceAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 2.0
    }

    // MARK: - XYDoughnutChartDataSource

    func numberOfSlicesInDoughnutChart(doughnutChart: XYDoughnutChart) -> Int {
        return slices?.count ?? 0;
    }

    func doughnutChart(doughnutChart: XYDoughnutChart, valueForSliceAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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

    // MARK: - DisplayPacketLogsSelectTableViewControllerDelegate

    func displayPacketLogSegmentDidSelected(segment: Int) {
        self.chartDataFilteringSegment = Coupon.Switch(rawValue: segment)!
        self.reBuildChartData()
        if self.traitCollection.horizontalSizeClass == .Regular {
            self.reloadChartView(true)
        }
    }

}
