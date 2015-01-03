class PacketLog: NSObject {

    var date: NSDate!
    var withCoupon: Int = 0
    var withoutCoupon: Int = 0

    init(date: NSDate, withCoupon: Int, withoutCoupon: Int) {
        self.date = date
        self.withCoupon = withCoupon
        self.withoutCoupon = withoutCoupon
    }
    
}
