import WatchKit
import QuartzCore
import GraphPONDataKit
import XYDoughnutChart

class AvailabilityChartScene: NSObject, XYDoughnutChartDataSource, XYDoughnutChartDelegate {

    var serviceCode: String!
    var duration: HdoService.Duration = .InThisMonth
    private var slices = [CGFloat]()

    init(serviceCode: String, duration: HdoService.Duration) {
        super.init()

        self.serviceCode = serviceCode
        self.duration = duration

        let hddService = PacketInfoManager.sharedManager.hddServiceForServiceCode(serviceCode)

        let packetSum = hddService?.hdoServices?.map { hdoInfo -> CGFloat in
            hdoInfo
                .summarizeServiceUsageInDuration(.InThisMonth, couponSwitch: .On)
                .reduce(0.0, combine: +)
        }

        if let usedPackets = packetSum {
            let used = usedPackets.reduce(0, combine:+)
            let available = CGFloat(hddService?.availableCouponVolume ?? 0)
            self.slices = [used, available];
        }
    }

    func drawImage(#frame: CGRect) -> UIImage {
        let chart = XYDoughnutChart(frame: frame)
        let size = chart.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, WKInterfaceDevice.currentDevice().screenScale)
        chart.dataSource = self
        chart.delegate = self
        chart.showLabel = false
        chart.radiusOffset = 0.8
        chart.reloadData()
        chart.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    var durationText: String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        let today = dateFormatter.stringFromDate(NSDate())
        let endOfThisMonth = dateFormatter.stringFromDate(NSDate().endDateOfMonth()!)
        return "\(today)-\(endOfThisMonth)"
    }

    var valueText: String {
        return PacketLog.stringForValue(self.slices.last)
    }

    // MARK: - XYDoughnutChartDataSource

    func numberOfSlicesInDoughnutChart(doughnutChart: XYDoughnutChart) -> Int {
        return slices.count
    }

    func doughnutChart(doughnutChart: XYDoughnutChart, valueForSliceAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return slices[indexPath.slice]
    }

    // MARK: - XYDoughnutChartDelegate

    func doughnutChart(doughnutChart: XYDoughnutChart, colorForSliceAtIndexPath indexPath: NSIndexPath) -> UIColor {
        if indexPath.slice == 0 {
            return UIColor.whiteColor()
        }

        return UIColor.whiteColor().colorWithAlphaComponent(0.5)
    }
   
}
