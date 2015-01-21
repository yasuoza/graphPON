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
                return self.packetLogsInThisMonth
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
            if let nickname = NSUserDefaults().objectForKey(self.hdoServiceCode) as String?  {
                return nickname
            }
            return self.number
        }
        set(nickname) {
            if nickname != "" {
                NSUserDefaults().setObject(nickname, forKey: self.hdoServiceCode)
            } else {
                NSUserDefaults().removeObjectForKey(self.hdoServiceCode)
            }
        }
    }
    var duration: Duration = .InThisMonth

    private var allPacketLogs: [PacketLog] = []
    private var packetLogsInThisMonth: [PacketLog] {
        get {
            return self.collectInThisMonthPacketLogs()
        }
    }

    init(hdoServiceCode: String, packetLogs: [PacketLog]) {
        super.init()
        self.hdoServiceCode = hdoServiceCode
        self.packetLogs = packetLogs
    }

    init(hdoServiceCode: String, number: String) {
        super.init()
        self.hdoServiceCode = hdoServiceCode
        self.number = Array(0..<3).reduce("", combine: { (var _number, index) -> String in
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
