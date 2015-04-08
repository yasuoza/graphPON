import UIKit
import Alamofire
import SwiftyJSON

class PacketInfoManager: NSObject {

    // MARK: - Singleton methods

    class var LatestPacketLogsDidFetchNotification: String {
        struct Notification {
            static let name = "graphPON.LatestPacketLogsDidFetchNotification"
        }
        return Notification.name
    }

    class var sharedManager : PacketInfoManager {
        struct Static {
            static let instance : PacketInfoManager = PacketInfoManager()
        }
        return Static.instance
    }

    private let dateFormatter = NSDateFormatter()

    private(set) var hddServices: [HddService] = []

    var hddServiceCodes: [String] {
        return self.hddServices.map { $0.hddServiceCode }
    }

    var hdoServiceCodes: [String] {
        return self.hddServices.reduce([] as [String], combine: { (var _hddServiceCodes, hddService) in
            if let hdoInfos = hddService.hdoServices {
                return _hddServiceCodes + hdoInfos.reduce([] as [String], combine: { (var _hdoInfoCodes, hdoInfo) in
                    return _hdoInfoCodes + [hdoInfo.hdoServiceCode]
                })
            } else {
                return []
            }
        })
    }

    var hdoServiceNumbers: [String] {
        return self.hddServices.reduce([] as [String], combine: { (var _hddServiceCodes, hddService) in
            if let hdoInfos = hddService.hdoServices {
                return _hddServiceCodes + hdoInfos.reduce([] as [String], combine: { (var _hdoInfoCodes, hdoInfo) in
                    return _hdoInfoCodes + [hdoInfo.number]
                })
            } else {
                return []
            }
        })
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

                var tmpHddServices: [HddService] = []
                for (_, hddServiceJSON) in json["couponInfo"] {
                    let hddServiceCode = hddServiceJSON["hddServiceCode"].stringValue
                    var tmpCoupons: [Coupon] = []
                    for (_, couponJSON) in hddServiceJSON["coupon"] {
                        let coupon = Coupon(volume: couponJSON["volume"].intValue)
                        tmpCoupons.append(coupon)
                    }
                    var tmpHdoServices: [HdoService] = []
                    for (_, hdoServiceJson) in hddServiceJSON["hdoInfo"] {
                        let hdoService = HdoService(
                            hdoServiceCode: hdoServiceJson["hdoServiceCode"].stringValue,
                            number: hdoServiceJson["number"].stringValue
                        )
                        hdoService.couponUse = hdoServiceJson["couponUse"].boolValue
                        tmpHdoServices.append(hdoService)
                    }
                    tmpHddServices.append(
                        HddService(hddServiceCode: hddServiceCode, coupons: tmpCoupons, hdoInfos: tmpHdoServices)
                    )
                }
                self.hddServices = tmpHddServices
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
        return self.hddServices.filter { $0.hddServiceCode == hddServiceCode }.first
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
