import UIKit
import JBChartFramework
import Alamofire
import SwiftyJSON

class SummaryChartViewController: BaseLineChartViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, HddServiceListTableViewControllerDelegate {

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

    private var chartDataSegment: ChartDataSegment = .All
    private var hddServiceCodes: [String] = []
    private var packetLogs: [[PacketLog]] = []
    private var chartLabels: [String] = []
    private var chartData: [[CGFloat]]! = []
    private var horizontalSymbols: [String] = []

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

        self.navigationItem.title = "Summary data"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserverForName(
            OAuth2Client.OAuthDidAuthorizeNotification,
            object: nil,
            queue: nil,
            usingBlock: { [unowned self] notification in
                self.fetchAndReloadLatestData()
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        switch OAuth2Client.sharedClient.state {
        case OAuth2Client.AuthorizationState.UnAuthorized:
            PromptLoginAlertView.initWithPreset(delegate: self).show()
        case OAuth2Client.AuthorizationState.Authorized:
            self.fetchAndReloadLatestData()
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
            hddServiceListViewController.hddServices = hddServiceCodes
        }
    }

    func fetchAndReloadLatestData() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        Alamofire.request(OAuth2Router.LogPacket)
            .validate(statusCode: 200..<300)
            .responseJSON { [unowned self] (_, _, json, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.loadingIndicatorView.stopAnimating()

                if error != nil {
                    PromptLoginAlertView.initWithPreset(delegate: self).show()
                    return
                }

                let json = JSON(json!)

                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyyMMdd"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US")

                if json["returnCode"].string != "OK" {
                    PromptLoginAlertView.initWithPreset(delegate: self).show()
                    return
                }

                for (hddArrayIndexStr: String, hddServiceJSON: JSON) in json["packetLogInfo"] {
                    self.hddServiceCodes.append(hddServiceJSON["hddServiceCode"].stringValue)

                    for (hdoArrayIndexStr: String, hdoServiceJson: JSON) in hddServiceJSON["hdoInfo"] {
                        self.chartLabels.append(hdoServiceJson["hdoServiceCode"].stringValue)

                        let hdoPacketLogAmounts = hdoServiceJson["packetLog"].arrayValue.map { packetLogJson -> PacketLog in
                            return PacketLog(
                                date: dateFormatter.dateFromString(packetLogJson["date"].stringValue)!,
                                withCoupon: packetLogJson["withCoupon"].intValue,
                                withoutCoupon: packetLogJson["withoutCoupon"].intValue
                            )
                        }
                        self.packetLogs.append(hdoPacketLogAmounts)
                    }
                    self.chartLabels.append("Total")
                    self.reloadChartView()
                }
        }
    }

    func reloadChartView() {
        self.initFakeData()
        self.navigationItem.title = self.hddServiceCodes.first
        self.chartViewContainerView.chartView.maximumValue = self.chartData.last!.last!
        if let footerView = self.chartViewContainerView.chartView.footerView as? LineChartFooterView {
            footerView.leftLabel.text = self.horizontalSymbols.first
            footerView.rightLabel.text = self.horizontalSymbols.last
            footerView.sectionCount = self.chartData.first?.count ?? 0
            footerView.hidden = false
        }
        self.displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: true)
    }

    @IBAction func chartSegmentedControlValueDidChanged(segmentedControl: UISegmentedControl) {
        self.chartDataSegment = ChartDataSegment(rawValue: segmentedControl.selectedSegmentIndex)!
        initFakeData()
        displayLatestTotalChartInformation()
        self.chartViewContainerView.reloadChartData()
    }

    func displayLatestTotalChartInformation() {
        let (label, date) = (self.chartLabels.last?, self.horizontalSymbols.last?)
        if label != nil && date != nil {
            self.chartInformationView.setTitleText("\(String(label!)) - \(String(date!))")
            self.chartInformationView.setHidden(false, animated: true)
        }
        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                var (value, unit) = (self.chartData.last?.last, "MB")
                if value != nil && value >= 100_0.0 {
                    (value, unit) =  (value! / 100_0.0, "GB")
                }
                let valueText = NSString(format: "%.01f", Float(value!))
                self.valueLabel.text = "\(valueText)\(unit)"
                self.valueLabel.alpha = 1.0
            },
            completion: nil
        )
    }

    // MARK: - Private methods

    func initFakeData() {
        var amountSummation = [CGFloat](count: packetLogs.first!.count, repeatedValue: 0.0)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")

        self.chartData = self.packetLogs.map { packets -> [CGFloat] in
            var sum = CGFloat(0.0)
            var index = 0
            return packets.map { packet -> CGFloat in
                switch self.chartDataSegment.rawValue {
                case 0:
                    sum += CGFloat(packet.withCoupon + packet.withoutCoupon)
                case 1:
                    sum += CGFloat(packet.withCoupon)
                case 2:
                    sum += CGFloat(packet.withoutCoupon)
                default:
                    break
                }
                amountSummation[index++] += sum
                self.horizontalSymbols.append(dateFormatter.stringFromDate(packet.date))
                return sum
            }
        }
        self.chartData.append(amountSummation)
    }

    // MARK: - JBLineChartViewDataSource

    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return UInt(self.chartData.count)
    }

    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(self.chartData.first?.count ?? 0)
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

        UIView.animateWithDuration(
            NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                var (value, unit) = (self.chartData[Int(lineIndex)][Int(horizontalIndex)], "MB")
                if value >= 100_0.0 {
                    (value, unit) =  (value / 100_0.0, "GB")
                }
                let valueText = NSString(format: "%.01f", Float(value))
                self.valueLabel.text = "\(valueText)\(unit)"
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
            completion: { [unowned self] finish in
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

    func hddServiceDidSelected(hddServiceIndex: Int) {
        self.navigationItem.title = self.hddServiceCodes[hddServiceIndex]

        func randomly(a: PacketLog, b: PacketLog) -> Bool {
            return arc4random() % 2 == 0
        }

        self.packetLogs = (0...2).map { sorted(self.packetLogs[$0], randomly) }
        initFakeData()
        self.chartViewContainerView.reloadChartData()
    }

}
