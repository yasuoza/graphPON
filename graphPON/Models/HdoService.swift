import UIKit

class HdoService: NSObject {

    enum Duration: Int {
        case InThisMonth = 0, InLast30Days = 1
    }

    private(set) var hdoServiceCode = ""
    private(set) var number = ""
    var coupons: [Coupon] = []
    var couponUse = true

    private var allPacketLogs: [PacketLog] = []
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
            if let nickname = NSUserDefaults.standardUserDefaults()
                .objectForKey("\(self.hdoServiceCode):nickName") as? String  {
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
