import WatchKit
import Foundation


class ChartInterfaceController: WKInterfaceController {

    enum ChartDataType {
        case Summary, Daily, Availability
    }

    @IBOutlet weak var durationLabel: WKInterfaceLabel!
    @IBOutlet weak var chartValueLabel: WKInterfaceLabel!
    @IBOutlet weak var chartImageView: WKInterfaceImage!
    @IBOutlet weak var durationControlButtonGroup: WKInterfaceGroup!
    @IBOutlet weak var inThisMonthButton: WKInterfaceButton!
    @IBOutlet weak var last30DaysButton: WKInterfaceButton!

    private var serviceCode: String!
    private var duration: HdoService.Duration = .InThisMonth
    private var dataType: ChartDataType = .Summary

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        if let context = context as? [String: AnyObject] {
            self.serviceCode = context["serviceCode"] as String
            self.reloadChartData()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
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
        self.setTitle("Summary")
        self.dataType = .Summary
        self.durationControlButtonGroup.setAlpha(1.0)
        self.reloadChartData()
    }

    @IBAction func showDailyChartMenuAction() {
        self.setTitle("Daily")
        self.dataType = .Daily
        self.durationControlButtonGroup.setAlpha(1.0)
        self.reloadChartData()
    }

    @IBAction func showAvailabilityChartMenuAction() {
        self.setTitle("Available")
        self.dataType = .Availability
        self.durationControlButtonGroup.setAlpha(0.0)
        self.reloadChartData()
    }

    // MARK: - Update views

    private func reloadChartData() {
        self.chartImageView.setImage(nil)

        let frame = CGRectMake(0, 0, 312, 184)
        switch self.dataType {
        case .Summary:
            let scene = SummaryChartScene(serviceCode: serviceCode, duration: duration)
            let image = scene.drawImage(frame: frame)
            self.chartImageView.setImage(image)
            self.chartValueLabel.setText(scene.valueText)
            self.durationLabel.setText(scene.durationText)
        case .Daily:
            let scene = DailyChartImageScene(serviceCode: serviceCode, duration: duration)
            let image = scene.drawImage(frame: frame)
            self.chartImageView.setImage(image)
            self.chartValueLabel.setText(scene.valueText)
            self.durationLabel.setText(scene.durationText)
        default:
            let scene = AvailabilityChartScene(serviceCode: serviceCode, duration: duration)
            let image = scene.drawImage(frame: frame)
            self.chartImageView.setImage(image)
            self.chartValueLabel.setText(scene.valueText)
            self.durationLabel.setText(scene.durationText)
        }
    }

}
