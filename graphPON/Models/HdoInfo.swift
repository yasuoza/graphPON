class HdoInfo: NSObject {

    enum Duration {
        case InThisMonth, InLast30Days
    }

    private(set) var hdoServiceCode: String  = ""
    private(set) var packetLogs: [PacketLog] = []
    var duration: Duration = .InThisMonth {
        didSet {
            switch self.duration {
            case .InThisMonth:
                self.packetLogs = self.packetLogsInThisMonth
            case .InLast30Days:
                self.packetLogs = self.allPacketLogs
            }
        }
    }

    private var allPacketLogs: [PacketLog] = []
    private lazy var packetLogsInThisMonth: [PacketLog] = { [unowned self] in
        return self.collectInThisMonthPacketLogs()
    }()

    init(hdoServiceCode: String, packetLogs: [PacketLog]) {
        super.init()

        self.hdoServiceCode = hdoServiceCode
        self.allPacketLogs = packetLogs
        self.packetLogs = packetLogsInThisMonth
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
