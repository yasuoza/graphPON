import WatchKit
import Foundation


class SummaryChartInterfaceController: WKInterfaceController {

    @IBOutlet weak var durationLabel: WKInterfaceLabel!
    @IBOutlet weak var chartValueLabel: WKInterfaceLabel!
    @IBOutlet weak var chartImageView: WKInterfaceImage!
    @IBOutlet weak var durationControlButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var inThisMonthButton: WKInterfaceButton!
    @IBOutlet weak var last30DaysButton: WKInterfaceButton!

    private var serviceCode: String!
    private var duration: HdoService.Duration = .InThisMonth

    override init() {
        super.init()

        PacketInfoManager.sharedManager.fetchLatestPacketLog(completion: { _ in
            let hddService = PacketInfoManager.sharedManager.hddServices.first
            Context.sharedContext.serviceCode = hddService?.hddServiceCode
            Context.sharedContext.serviceNickname = hddService?.nickName
        })
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        NSNotificationCenter.defaultCenter().addObserverForName(
            PacketInfoManager.LatestPacketLogsDidFetchNotification,
            object: nil, queue: nil, usingBlock: { _ in
                if let serviceCode = Context.sharedContext.serviceCode {
                    self.serviceCode = serviceCode
                    self.reloadChartData()
                }
        })
    }

    override func willActivate() {
        super.willActivate()

        if self.serviceCode != Context.sharedContext.serviceCode {
            self.serviceCode = Context.sharedContext.serviceCode
            self.reloadChartData()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - Actions

    @IBAction func InThisMonthButtonAction() {
        self.inThisMonthButton.setBackgroundColor(UIColor.blackColor().colorWithAlphaComponent(0.8))
        self.last30DaysButton.setBackgroundColor(UIColor.clearColor())
        self.duration = .InThisMonth
        self.reloadChartData()
    }

    @IBAction func last30DaysButtonAction() {
        self.inThisMonthButton.setBackgroundColor(UIColor.clearColor())
        self.last30DaysButton.setBackgroundColor(UIColor.blackColor().colorWithAlphaComponent(0.8))
        self.duration = .InLast30Days
        self.reloadChartData()
    }

    @IBAction func showSummaryChartMenuAction() {
        self.presentControllerWithName("ServiceListInterfaceController", context: nil)
        self.reloadChartData()
    }

    // MARK: - Update views

    private func reloadChartData() {
        let frame = CGRectMake(0, 0, 312, 184)
        let scene = SummaryChartScene(serviceCode: serviceCode, duration: duration)
        let image = scene.drawImage(frame: frame)
        self.chartImageView.setImage(image)
        self.chartValueLabel.setText(scene.valueText)
        self.durationLabel.setText(scene.durationText)
        self.setTitle(Context.sharedContext.serviceNickname)
    }

}
