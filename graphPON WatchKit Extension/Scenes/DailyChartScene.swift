import WatchKit
import QuartzCore
import JBChartFramework

class DailyChartScene: NSObject, JBBarChartViewDataSource, JBBarChartViewDelegate {

    var serviceCode: String!
    var duration: HdoService.Duration = .InThisMonth
    private var chartData = [CGFloat]()

    init(serviceCode: String, duration: HdoService.Duration) {
        super.init()

        self.serviceCode = serviceCode
        self.duration = duration

        let chartDatas: [[CGFloat]]? = PacketInfoManager.sharedManager
            .hddServiceForServiceCode(serviceCode)?.hdoServices?
            .map {
                $0.summarizeServiceUsageInDuration(duration, couponSwitch: .On)
        }

        if let chartDatas = chartDatas {
            if chartDatas.count > 1 {
                let initial = [CGFloat](count: chartDatas.first!.count, repeatedValue: 0.0)

                self.chartData = chartDatas.reduce(initial, combine: { (arr, data) in
                    return map(Zip2(arr, data), +)
                })
            }
        }
    }

    func drawImage(#frame: CGRect) -> UIImage {
        let chart = JBBarChartView(frame: frame)
        let size = chart.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, WKInterfaceDevice.currentDevice().screenScale)
        chart.dataSource = self
        chart.delegate = self
        chart.minimumValue = 0.0
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
            return "\(packetLogs.last!.dateText())"
        }

        return ""
    }

    var valueText: String {
        return PacketLog.stringForValue(self.chartData.last)
    }

    // MARK: - JBBarChartViewDataSource

    func numberOfBarsInBarChartView(barChartView: JBBarChartView!) -> UInt {
        return UInt(chartData.count)
    }

    // MARK: - JBBarChartViewDelegate

    func barChartView(barChartView: JBBarChartView!, colorForBarViewAtIndex index: UInt) -> UIColor! {
        return UIColor.whiteColor()
    }

    func barChartView(barChartView: JBBarChartView!, heightForBarViewAtIndex index: UInt) -> CGFloat {
        return chartData[Int(index)]
    }
    
}
