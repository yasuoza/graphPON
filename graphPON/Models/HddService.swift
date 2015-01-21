import UIKit

class HddService: NSObject {
    private(set) var hddServiceCode: String!
    private(set) var hdoServices: [HdoService]?
    private(set) var coupons: [Coupon] = []
    var hdoServiceCodes: [String] {
        get {
            if let hdoService = hdoServices {
                return hdoService.reduce([], combine: { (var arr, hdoInfo) -> [String] in
                    return arr + [hdoInfo.hdoServiceCode]
                })
            } else {
                return []
            }
        }
    }
    var nickName: String {
        get {
            if let nickname = NSUserDefaults().objectForKey("\(self.hddServiceCode):nickName") as String?  {
                return nickname
            }
            return self.hddServiceCode
        }
        set(nickname) {
            if nickname != "" {
                NSUserDefaults().setObject(nickname, forKey: "\(self.hddServiceCode):nickName")
            } else {
                NSUserDefaults().removeObjectForKey("\(self.hddServiceCode):nickName")
            }
        }
    }

    init(hddServiceCode: String, hdoInfos: [HdoService]) {
        super.init()
        self.hddServiceCode = hddServiceCode
        self.hdoServices = hdoInfos
    }

    init(hddServiceCode: String, coupons: [Coupon], hdoInfos: [HdoService]) {
        super.init()
        self.hddServiceCode = hddServiceCode
        self.coupons = coupons
        self.hdoServices = hdoInfos
    }

    func availableCouponVolume() -> Int {
        return self.coupons.reduce(0, combine: { (sum , coupon) in
            return sum + coupon.volume
        })
    }

    func availableCouponVolumeString() -> String {
        var available = Float(self.availableCouponVolume())
        let unit: String = { _ -> String in
            if available >= 1_000.0 {
                available = available / 1_000.0
                return "GB"
            }
            return "MB"
            }()
        return NSString(format: "%.01f", available) + unit
    }

    func hdoServiceForServiceCode(hdoServiceCode: String) -> HdoService? {
        if let hdoServiceIndex = find(self.hdoServiceCodes, hdoServiceCode) {
            return self.hdoServices?[hdoServiceIndex]
        }
        return nil
    }

}