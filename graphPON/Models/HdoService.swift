import UIKit

class HdoService: NSObject {

    enum Duration: Int {
        case InThisMonth = 0, InLast30Days = 1
    }

    private(set) var hdoServiceCode = ""
    private(set) var number = ""
    var couponUse = true
    var packetLogs: [PacketLog] {
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
    var nickName: String {
        get {
            if let nickname = NSUserDefaults.standardUserDefaults().objectForKey("\(self.hdoServiceCode):nickName") as String?  {
                return nickname
            }
            return self.number
        }
        set(nickname) {
            if nickname != "" {
                NSUserDefaults.standardUserDefaults().setObject(nickname, forKey: "\(self.hdoServiceCode):nickName")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("\(self.hdoServiceCode):nickName")
            }
        }
    }
    var duration: Duration = .InThisMonth

    private var allPacketLogs: [PacketLog] = []

    init(hdoServiceCode: String, packetLogs: [PacketLog]) {
        super.init()
        self.hdoServiceCode = hdoServiceCode
        self.packetLogs = packetLogs
    }

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
            let range = Range(start: advance(number.startIndex, startIndex), end: advance(number.startIndex, (index + 1) * 4 - 1))
            return _number + number.substringWithRange(range)
        })
    }

    func summarizeServiceUsageInDuration(duration: HdoService.Duration, couponSwitch: Coupon.Switch) -> [CGFloat] {
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
            NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.YearCalendarUnit,
            fromDate: NSDate()
        )
        return self.allPacketLogs.filter { (packetLog) in
            let component = NSCalendar.currentCalendar().components(
                NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.YearCalendarUnit,
                fromDate: packetLog.date
            )
            if component.year < todayComp.year || component.month < todayComp.month {
                return false
            }
            return true
        }
    }

}
