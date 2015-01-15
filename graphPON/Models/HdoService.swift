import UIKit

class HdoService: NSObject {

    enum Duration: Int {
        case InThisMonth = 0, InLast30Days = 1
    }

    private(set) var hdoServiceCode = ""
    private(set) var number = ""
    private(set) var packetLogs: [PacketLog] = []
    var duration: Duration = .InThisMonth {
        didSet {
            self.setPacketLogsDependsOnDuration()
        }
    }
    var allPacketLogs: [PacketLog] = [] {
        didSet {
            self.setPacketLogsDependsOnDuration()
        }
    }
    private lazy var packetLogsInThisMonth: () -> [PacketLog] = { [unowned self] in
        return self.collectInThisMonthPacketLogs()
    }

    init(hdoServiceCode: String, packetLogs: [PacketLog]) {
        super.init()

        self.hdoServiceCode = hdoServiceCode
        self.allPacketLogs = packetLogs
        self.packetLogs = self.packetLogsInThisMonth()
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

    private func setPacketLogsDependsOnDuration() {
        switch self.duration {
        case .InThisMonth:
            self.packetLogs = self.packetLogsInThisMonth()
        case .InLast30Days:
            self.packetLogs = self.allPacketLogs
        }
    }

}
