class PacketInfoManager: NSObject {

    private var logInfo: [String: Array<HdoInfo>]! = [String: Array<HdoInfo>]()

    class var sharedManager : PacketInfoManager {
        struct Static {
            static let instance : PacketInfoManager = PacketInfoManager()
        }
        return Static.instance
    }

    func fetchLatestData() {
        let serviceCode = "hdd88134628"
        self.logInfo[serviceCode] = self.logInfo[serviceCode] ?? []

        let today = NSDate()
        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        var comps = calendar.components(
            (NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay), fromDate: today
        )
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        comps.month = 11

        let hdoInfo0 = HdoInfo(hdoServiceCode: "hdo88134635")
        let arr0 = [21, 11, 32, 14, 67, 11, 66, 45, 100,
            44, 31, 38, 53, 70, 2, 1, 33, 52, 34, 11,
            11, 50, 2, 2, 34, 44, 63, 102, 109, 9, 24]
        var dateCounter = 0
        arr0.map { (var val: Int) -> () in
            comps.day = ++dateCounter
            let date = calendar.dateFromComponents(comps)!
            let packetLog = PacketLog(date: date, withCoupon: UInt(val), withoutCoupon: 0)
            hdoInfo0.addPacketLog(packetLog)
        }
        self.logInfo[serviceCode]?.append(hdoInfo0)

        let hdoInfo1 = HdoInfo(hdoServiceCode: "hdo88747972")
        let arr1 = [7, 3, 12, 11, 4, 37, 6, 33, 1, 18,
            1, 1, 1, 12, 1, 1, 1, 15, 1, 1, 1,
            57, 1, 1, 5, 17, 30, 3, 36, 26, 1]
        dateCounter = 0
        arr1.map { (var val: Int) -> () in
            comps.day = ++dateCounter
            let date = calendar.dateFromComponents(comps)!
            let packetLog = PacketLog(date: date, withCoupon: UInt(val), withoutCoupon: 0)
            hdoInfo1.addPacketLog(packetLog)
        }
        self.logInfo[serviceCode]?.append(hdoInfo1)

        let hdoInfo2 = HdoInfo(hdoServiceCode: "hdo88747989")
        let arr2 = [1, 1, 1, 65, 1, 22, 18, 23, 12,
            13, 2, 14, 2, 29, 8, 1, 7, 5, 1,
            4, 21, 39, 19, 1, 10, 37, 49, 66, 80, 6, 24]
        dateCounter = 0
        arr2.map { (var val: Int) -> () in
            comps.day = ++dateCounter
            let date = calendar.dateFromComponents(comps)!
            let packetLog = PacketLog(date: date, withCoupon: UInt(val), withoutCoupon: 0)
            hdoInfo2.addPacketLog(packetLog)
        }
        self.logInfo[serviceCode]?.append(hdoInfo2)
    }

    func packetLogsForServiceCode(serviceCode: String) -> Array<HdoInfo>? {
        return self.logInfo[serviceCode]
    }
   
}
