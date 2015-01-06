class HdoInfo: NSObject {

    private(set) var hdoServiceCode: String     = ""
    private(set) var packetLogs: [PacketLog]    = []
    lazy var packetLogsInThisMonth: [PacketLog] = { [unowned self] in
        return self.collectInThisMonthPacketLogs()
    }()

    init(hdoServiceCode: String, packetLogs: [PacketLog]) {
        super.init()

        self.hdoServiceCode = hdoServiceCode
        self.packetLogs = packetLogs
    }

    // MARK: - Private

    private func collectInThisMonthPacketLogs() -> [PacketLog] {
        let todayComp = NSCalendar.currentCalendar().components(
            NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.YearCalendarUnit,
            fromDate: NSDate()
        )
        return self.packetLogs.filter { (packetLog) in
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
