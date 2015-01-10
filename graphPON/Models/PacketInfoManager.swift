import Alamofire
import SwiftyJSON

class PacketInfoManager: NSObject {

    class var LatestPacketLogsDidFetchNotification: String {
        struct Notification {
            static let name = "graphPON.LatestPacketLogsDidFetchNotification"
        }
        return Notification.name
    }

    private let dateFormatter = NSDateFormatter()

    private(set) var hddServiceInfoForServiceCode: [String: [HdoInfo]]! = [String: [HdoInfo]]()

    lazy var hddServiceCodes: () -> [String]? = { [unowned self] in
        return Array(self.hddServiceInfoForServiceCode.keys)
    }

    lazy var hdoServiceCodes: () -> [String]? = { [unowned self] in
        let values = Array(self.hddServiceInfoForServiceCode.values)
        return values.reduce([], combine: { (var arr, hdoInfos) -> [String] in
            return arr + hdoInfos.map { hdoInfo in
                hdoInfo.hdoServiceCode
            }
        })
    }

    // MARK: - Singleton methods

    class var sharedManager : PacketInfoManager {
        struct Static {
            static let instance : PacketInfoManager = PacketInfoManager()
        }
        return Static.instance
    }

    // MARK: - Instance methods

    override init() {
        super.init()

        self.dateFormatter.dateFormat = "yyyyMMdd"
        self.dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
    }

    func fetchLatestPacketLog(completion _completion: ((error: NSError?)->())?) {
        var tmpHddServiceInfoForServiceCode = [String: [HdoInfo]]()

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(OAuth2Router.LogPacket)
            .responseJSON { (_, response, json, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

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
                    let serviceCode = hddServiceJSON["hddServiceCode"].stringValue
                    tmpHddServiceInfoForServiceCode[serviceCode] = tmpHddServiceInfoForServiceCode[serviceCode] ?? []
                    for (_, hdoServiceJson) in hddServiceJSON["hdoInfo"] {
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
                        let hdoInfo = HdoInfo(
                            hdoServiceCode: hdoServiceJson["hdoServiceCode"].stringValue,
                            packetLogs: hdoPacketLogs
                        )
                        tmpHddServiceInfoForServiceCode[serviceCode]!.append(hdoInfo)
                    }
                }
                self.hddServiceInfoForServiceCode = tmpHddServiceInfoForServiceCode
                NSNotificationCenter.defaultCenter().postNotificationName(
                    PacketInfoManager.LatestPacketLogsDidFetchNotification,
                    object: nil
                )
                _completion?(error: nil)
        }
    }

    func packetLogsForServiceCode(serviceCode: String) -> [HdoInfo]? {
        return self.hddServiceInfoForServiceCode[serviceCode]
    }
   
}
