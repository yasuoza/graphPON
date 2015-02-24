import UIKit

class HddService: NSObject {
    let hddServiceCode: String!
    let hdoServices: [HdoService]?
    let coupons: [Coupon]!
    var hdoServiceCodes: [String] {
        get {
            if let hdoService = hdoServices {
                return hdoService.reduce([] as [String], combine: { (var arr, hdoInfo) in
                    return arr + [hdoInfo.hdoServiceCode]
                })
            } else {
                return []
            }
        }
    }
    var nickName: String {
        get {
            if let nickname = NSUserDefaults.standardUserDefaults()
                .objectForKey("\(self.hddServiceCode):nickName") as? String  {
                return nickname
            }
            return self.hddServiceCode
        }
        set(nickname) {
            if nickname != "" {
                NSUserDefaults.standardUserDefaults().setObject(nickname, forKey: "\(self.hddServiceCode):nickName")
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey("\(self.hddServiceCode):nickName")
            }
        }
    }

    init(hddServiceCode: String, hdoInfos: [HdoService]) {
        self.hddServiceCode = hddServiceCode
        self.coupons = []
        self.hdoServices = hdoInfos
    }

    init(hddServiceCode: String, coupons: [Coupon], hdoInfos: [HdoService]) {
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
        return NSString(format: "%.01f", available) as! String + unit
    }

    func hdoServiceForServiceCode(hdoServiceCode: String) -> HdoService? {
        if let hdoServiceIndex = find(self.hdoServiceCodes, hdoServiceCode) {
            return self.hdoServices?[hdoServiceIndex]
        }
        return nil
    }

}