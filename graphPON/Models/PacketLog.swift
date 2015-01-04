class PacketLog: NSObject {

    var date: NSDate!
    var withCoupon: Int = 0
    var withoutCoupon: Int = 0

    private let dateFormatter = NSDateFormatter()

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
