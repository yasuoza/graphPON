class PacketLog: NSObject {

    var date: NSDate!
    var withCoupon: Int = 0
    var withoutCoupon: Int = 0

    private let dateFormatter = NSDateFormatter()

    // MARK: - Singleton methods

    class func stringForValue(var packetValue: CGFloat?) -> String {
        packetValue = packetValue ?? 0.0
        let unit: String = { _ -> String in
            if packetValue >= 1_000.0 {
                packetValue = packetValue! / 1_000.0
                return "GB"
            }
            return "MB"
        }()
        return NSString(format: "%.01f", Float(packetValue!)) + unit
    }

    // MARK: - Instance methods

    init(date: NSDate, withCoupon: Int, withoutCoupon: Int) {
        self.date = date
        self.withCoupon = withCoupon
        self.withoutCoupon = withoutCoupon

        self.dateFormatter.dateFormat = "MM/dd"
        self.dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
    }

    func dateText() -> String {
        return dateFormatter.stringFromDate(self.date)
    }

}
