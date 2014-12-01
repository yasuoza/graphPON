class PacketLog: NSObject {

    var date: NSDate!
    var withCoupon: UInt = 0
    var withoutCoupon: UInt = 0

    init(date: NSDate, withCoupon: UInt, withoutCoupon: UInt) {
        self.date = date
        self.withCoupon = withCoupon
        self.withoutCoupon = withoutCoupon
    }
    
}
