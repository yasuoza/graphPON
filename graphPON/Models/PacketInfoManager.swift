import UIKit
import Alamofire
import SwiftyJSON

class PacketInfoManager: NSObject {

    // MARK: - Singleton variables

    static let LatestPacketLogsDidFetchNotification = "graphPON.LatestPacketLogsDidFetchNotification"
    static let sharedManager = PacketInfoManager()

    // MARK: - Instance variables

    private let dateFormatter = NSDateFormatter()

    private(set) var hddServices = [HddService]()

    var hddServiceCodes: [String] {
        return self.hddServices.map { $0.hddServiceCode }
    }

    var hdoServiceCodes: [String] {
        return self.hddServices.flatMap { $0.hdoServices ?? [] }.map { $0.hdoServiceCode }
    }

    var hdoServiceNumbers: [String] {
        return self.hddServices.flatMap { $0.hdoServices ?? [] }.map { $0.number }
    }

    // MARK: - Instance methods

    override init() {
        super.init()

        self.dateFormatter.dateFormat = "yyyyMMdd"
        self.dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
    }

    func fetchLatestCouponInfo(completion _completion: ((error: NSError?)->())?) {
        Alamofire.request(OAuth2Router.Coupon)
            .responseJSON { (_, response, json, error) in

                if error != nil {
                    _completion?(error: error)
                    return
                }

                let json = JSON(json!)

                switch response!.statusCode {
                case 403:
                    // return Authentication error
                    let apiError = NSError(
                        domain: OAuth2Router.APIErrorDomain,
                        code: OAuth2Router.AuthorizationFailureErrorCode,
                        userInfo: ["resultCode": json["resultCode"].stringValue]
                    )
                    OAuth2Client.sharedClient.deauthorize()
                    _completion?(error: apiError)
                    return
                case 429:
                    let apiError = NSError(
                        domain: OAuth2Router.APIErrorDomain,
                        code: OAuth2Router.TooManyRequestErrorCode,
                        userInfo: ["resultCode": json["resultCode"].stringValue]
                    )
                    _completion?(error: apiError)
                    return
                case 400...503:
                    let apiError = NSError(
                        domain: OAuth2Router.APIErrorDomain,
                        code: OAuth2Router.UnknownErrorCode,
                        userInfo: ["resultCode": json["resultCode"].stringValue]
                    )
                    _completion?(error: apiError)
                    return
                default:
                    break
                }

                var hddServices: [HddService] = []
                for (_, hddServiceJSON) in json["couponInfo"] {
                    let hddServiceCode = hddServiceJSON["hddServiceCode"].stringValue
                    var tmpCoupons: [Coupon] = []
                    for (_, couponJSON) in hddServiceJSON["coupon"] {
                        let coupon = Coupon(volume: couponJSON["volume"].intValue)
                        tmpCoupons.append(coupon)
                    }
                    var hdoServices: [HdoService] = []
                    for (_, hdoServiceJson) in hddServiceJSON["hdoInfo"] {
                        let hdoService = HdoService(
                            hdoServiceCode: hdoServiceJson["hdoServiceCode"].stringValue,
                            number: hdoServiceJson["number"].stringValue
                        )
                        hdoService.couponUse = hdoServiceJson["couponUse"].boolValue
                        for (_, simCouponJSON) in hdoServiceJson["coupon"] {
                            let simCoupon = Coupon(volume: simCouponJSON["volume"].intValue)
                            hdoService.coupons.append(simCoupon)
                        }
                        hdoServices.append(hdoService)
                    }
                    hddServices.append(
                        HddService(hddServiceCode: hddServiceCode, coupons: tmpCoupons, hdoServices: hdoServices)
                    )
                }
                self.hddServices = hddServices
                _completion?(error: nil)
        }
    }

    func fetchLatestPacketLog(completion _completion: ((error: NSError?)->())?) {
        self.fetchLatestCouponInfo(completion: { error in
            if error != nil {
                _completion?(error: error)
                return
            }

            Alamofire.request(OAuth2Router.LogPacket)
                .responseJSON { (_, response, json, error) in
                    if error != nil {
                        _completion?(error: error)
                        return
                    }

                    let json = JSON(json!)

                    switch response!.statusCode {
                    case 403:
                        // return Authentication error
                        let apiError = NSError(
                            domain: OAuth2Router.APIErrorDomain,
                            code: OAuth2Router.AuthorizationFailureErrorCode,
                            userInfo: ["resultCode": json["resultCode"].stringValue]
                        )
                        OAuth2Client.sharedClient.deauthorize()
                        _completion?(error: apiError)
                        return
                    case 429:
                        let apiError = NSError(
                            domain: OAuth2Router.APIErrorDomain,
                            code: OAuth2Router.TooManyRequestErrorCode,
                            userInfo: ["resultCode": json["resultCode"].stringValue]
                        )
                        _completion?(error: apiError)
                        return
                    case 400...503:
                        let apiError = NSError(
                            domain: OAuth2Router.APIErrorDomain,
                            code: OAuth2Router.UnknownErrorCode,
                            userInfo: ["resultCode": json["resultCode"].stringValue]
                        )
                        _completion?(error: apiError)
                        return
                    default:
                        break
                    }

                    for (_, hddServiceJSON) in json["packetLogInfo"] {
                        let hddServiceCode = hddServiceJSON["hddServiceCode"].stringValue
                        for (_, hdoServiceJson) in hddServiceJSON["hdoInfo"] {
                            let hdoServiceCode = hdoServiceJson["hdoServiceCode"].stringValue
                            var hdoPacketLogs: [PacketLog] = []
                            for (_, packetLogJson) in hdoServiceJson["packetLog"] {
                                let date = self.dateFormatter.dateFromString(packetLogJson["date"].stringValue)!
                                let packetLog = PacketLog(
                                    date: date,
                                    withCoupon: packetLogJson["withCoupon"].intValue,
                                    withoutCoupon: packetLogJson["withoutCoupon"].intValue
                                )
                                hdoPacketLogs.append(packetLog)
                            }
                            if let hddService = self.hddServiceForServiceCode(hddServiceCode) {
                                if let hdoService = hddService.hdoServiceForServiceCode(hdoServiceCode) {
                                    hdoService.packetLogs = hdoPacketLogs
                                }
                            }
                        }
                    }

                    _completion?(error: nil)

                    NSNotificationCenter.defaultCenter().postNotificationName(
                        PacketInfoManager.LatestPacketLogsDidFetchNotification,
                        object: nil
                    )
            }
        })

    }

    func hddServiceForServiceCode(hddServiceCode: String?) -> HddService? {
        return hddServiceCode.flatMap { find(self.hddServiceCodes, $0) }.flatMap { self.hddServices[$0] }
    }

    func hdoServiceForServiceCode(hdoServiceCode: String?) -> HdoService? {
        if let hdoServiceCode = hdoServiceCode {
            for hddService in self.hddServices {
                if let hdoService = hddService.hdoServiceForServiceCode(hdoServiceCode) {
                    return hdoService
                }
            }
        }
        return nil
    }

}
