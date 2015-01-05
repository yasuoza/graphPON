import Alamofire
import SwiftyJSON

class PacketInfoManager: NSObject {

    private let dateFormatter = NSDateFormatter()

    private(set) var hddServiceInfoForServiceCode: [String: [HdoInfo]]! = [String: [HdoInfo]]()

    lazy var hddServiceCodes: () -> [String]? = { [unowned self] in
        return Array(self.hddServiceInfoForServiceCode.keys)
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

    func fetchLatestPacketLog(completion _completion: (error: NSError?)->()) {
        var tmpHddServiceInfoForServiceCode = [String: [HdoInfo]]()

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(OAuth2Router.LogPacket)
            .responseJSON { (_, response, json, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                if error != nil {
                    _completion(error: error)
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
                    return _completion(error: apiError)
                case 429:
                    let apiError = NSError(
                        domain: OAuth2Router.APIErrorDomain,
                        code: OAuth2Router.TooManyRequestErrorCode,
                        userInfo: ["resultCode": json["resultCode"].stringValue]
                    )
                    return _completion(error: apiError)
                case 400...503:
                    let apiError = NSError(
                        domain: OAuth2Router.APIErrorDomain,
                        code: OAuth2Router.UnknownErrorCode,
                        userInfo: ["resultCode": json["resultCode"].stringValue]
                    )
                    return _completion(error: apiError)
                default:
                    break
                }

                for (hddArrayIndexStr: String, hddServiceJSON: JSON) in json["packetLogInfo"] {
                    let serviceCode = hddServiceJSON["hddServiceCode"].stringValue
                    tmpHddServiceInfoForServiceCode[serviceCode] = tmpHddServiceInfoForServiceCode[serviceCode] ?? []
                    for (hdoArrayIndexStr: String, hdoServiceJson: JSON) in hddServiceJSON["hdoInfo"] {
                        if let packetLogJsons = hdoServiceJson["packetLog"].array {
                            let hdoPacketLogs = packetLogJsons.map { packetLogJson -> PacketLog in
                                return PacketLog(
                                    date: self.dateFormatter.dateFromString(packetLogJson["date"].stringValue)!,
                                    withCoupon: packetLogJson["withCoupon"].intValue,
                                    withoutCoupon: packetLogJson["withoutCoupon"].intValue
                                )
                            }
                            let hdoInfo = HdoInfo(
                                hdoServiceCode: hdoServiceJson["hdoServiceCode"].stringValue,
                                packetLogs: hdoPacketLogs
                            )
                            tmpHddServiceInfoForServiceCode[serviceCode]!.append(hdoInfo)
                        }
                    }
                }
                self.hddServiceInfoForServiceCode = tmpHddServiceInfoForServiceCode
                _completion(error: nil)
        }
    }

    func packetLogsForServiceCode(serviceCode: String) -> [HdoInfo]? {
        return self.hddServiceInfoForServiceCode[serviceCode]
    }
   
}
