import WatchKit
import QuartzCore
import GraphPONDataKit
import JBChartFramework

class SummaryChartScene: NSObject, JBLineChartViewDataSource, JBLineChartViewDelegate {

    var serviceCode: String!
    var duration: HdoService.Duration = .InThisMonth
    private var chartData = [CGFloat]()

    init(serviceCode: String, duration: HdoService.Duration) {
        super.init()

        self.serviceCode = serviceCode
        self.duration = duration

        let displayAllDataUsage = GPUserDefaults.sharedDefaults().boolForKey("display_all_data_usage")
        let couponSwitch: Coupon.Switch = displayAllDataUsage ? .All : .On

        self.chartData = PacketInfoManager.sharedManager
            .hddServiceForServiceCode(serviceCode)?
            .summarizeServiceUsageInDuration(duration, couponSwitch: couponSwitch).last ?? []
    }

    func drawImage(#frame: CGRect) -> UIImage {
        let chart = JBLineChartView(frame: frame)
        let size = chart.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, WKInterfaceDevice.currentDevice().screenScale)
        chart.dataSource = self
        chart.delegate = self
        chart.reloadData()
        chart.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    var durationText: String {
        let packetLogs = PacketInfoManager.sharedManager
            .hddServiceForServiceCode(serviceCode)?.hdoServices?.first?.packetLogs

        if let packetLogs = packetLogs {
            return "\(packetLogs.first!.dateText())-\(packetLogs.last!.dateText())"
        }

        return ""
    }

    var valueText: String {
        return PacketLog.stringForValue(self.chartData.last)
    }

    // MARK: - JBLineChartViewDataSource

    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return UInt(1)
    }

    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(chartData.count)
    }

    // MARK: - JBLineChartViewDelegate

    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return chartData[Int(horizontalIndex)]
    }

    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.whiteColor()
    }

    func lineChartView(lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
        return 0.0
    }

    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }

    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.whiteColor().colorWithAlphaComponent(0.8)
    }

}
