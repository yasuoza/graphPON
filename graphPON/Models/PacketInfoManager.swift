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

    private(set) var hddServices: [HddService] = []

    lazy var hddServiceCodes: () -> [String] = { [unowned self] in
        return self.hddServices.map { $0.hddServiceCode }
    }

    lazy var hdoServiceCodes: () -> [String] = { [unowned self] in
        return self.hddServices.reduce([], combine: { (var _hddServiceCodes, hddService) -> [String] in
            if let hdoInfos = hddService.hdoServices {
                return _hddServiceCodes + hdoInfos.reduce([], combine: { (var _hdoInfoCodes, hdoInfo) -> [String] in
                    return _hdoInfoCodes + [hdoInfo.hdoServiceCode]
                })
            } else {
                return []
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
        var tmpHddServices: [HddService] = []

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
                    var serviceCode = hddServiceJSON["hddServiceCode"].stringValue
                    var tmpHdoInfos: [HdoService] = []
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
                        let hdoInfo = HdoService(
                            hdoServiceCode: hdoServiceJson["hdoServiceCode"].stringValue,
                            packetLogs: hdoPacketLogs
                        )
                        tmpHdoInfos.append(hdoInfo)
                    }
                    let hddService = HddService(hddServiceCode: serviceCode, hdoInfos: tmpHdoInfos)
                    tmpHddServices.append(hddService)
                }
                self.hddServices = tmpHddServices
                NSNotificationCenter.defaultCenter().postNotificationName(
                    PacketInfoManager.LatestPacketLogsDidFetchNotification,
                    object: nil
                )
                _completion?(error: nil)
        }
    }

    func hddServiceForServiceCode(hddServiceCode: String) -> HddService? {
        return self.hddServices.filter { $0.hddServiceCode == hddServiceCode }.first
    }

    func hdoServiceForServiceCode(hdoServiceCode: String) -> HdoService? {
        for hddService in self.hddServices {
            if let hdoService = hddService.hdoServiceForServiceCode(hdoServiceCode) {
                return hdoService
            }
        }
        return nil
    }

}
