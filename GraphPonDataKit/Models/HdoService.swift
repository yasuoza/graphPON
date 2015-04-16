import UIKit

public class HdoService: NSObject {

    public enum Duration: Int {
        case InThisMonth = 0, InLast30Days = 1
    }

    public private(set) var hdoServiceCode = ""
    public private(set) var number = ""

    public var couponUse = true

    var coupons: [Coupon] = []

    private var allPacketLogs: [PacketLog] = []

    public var packetLogs: [PacketLog] {
        get {
            switch self.duration {
            case .InThisMonth:
                return self.collectInThisMonthPacketLogs()
            case .InLast30Days:
                return self.allPacketLogs
            }
        }
        set(packets) {
            self.allPacketLogs = packets
        }
    }

    public var nickName: String {
        get {
            if let nickname = GPUserDefaults.sharedDefaults()
                .objectForKey("\(self.hdoServiceCode):nickName") as? String  {
                return nickname
            }
            return self.number
        }
        set(nickname) {
            if nickname != "" {
                GPUserDefaults.sharedDefaults().setObject(nickname, forKey: "\(self.hdoServiceCode):nickName")
            } else {
                GPUserDefaults.sharedDefaults().removeObjectForKey("\(self.hdoServiceCode):nickName")
            }
        }
    }

    public var duration: Duration = .InThisMonth

    init(hdoServiceCode: String, number: String) {
        super.init()
        self.hdoServiceCode = hdoServiceCode
        self.number = Array(0..<3).reduce("", combine: { (var _number, index) in
            var startIndex = index * 4 - 1
            if startIndex < 0 {
                startIndex = 0
            } else {
                _number += "-"
            }
            let range = Range(
                start: advance(number.startIndex, startIndex),
                end: advance(number.startIndex, (index + 1) * 4 - 1)
            )
            return _number + number.substringWithRange(range)
        })
    }

    public func summarizeServiceUsageInDuration(duration: HdoService.Duration, couponSwitch: Coupon.Switch) -> [CGFloat] {
        self.duration = duration
        return packetLogs.reduce([] as [CGFloat], combine: { (arr, packetLog) in
            switch couponSwitch {
            case .All:
                return arr + [CGFloat(packetLog.withCoupon + packetLog.withoutCoupon)]
            case .On:
                return arr + [CGFloat(packetLog.withCoupon)]
            case .Off:
                return arr + [CGFloat(packetLog.withoutCoupon)]
            }
        })
    }

    // MARK: - Private

    private func collectInThisMonthPacketLogs() -> [PacketLog] {
        let todayComp = NSCalendar.currentCalendar().components(
            .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear,
            fromDate: NSDate()
        )
        return self.allPacketLogs.filter { (packetLog) in
            let component = NSCalendar.currentCalendar().components(
                .CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear,
                fromDate: packetLog.date
            )
            if component.year < todayComp.year || component.month < todayComp.month {
                return false
            }
            return true
        }
    }

}
