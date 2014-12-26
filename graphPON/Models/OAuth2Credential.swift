import Foundation

class OAuth2Credential: NSObject, NSCoding {
    let accessToken: String = ""
    let tokenType: String = ""
    let expiryDate: NSDate = NSDate()

    init(dictionary dictionaryValue: [NSObject : AnyObject], error: NSErrorPointer) {
        for (k, v) in dictionaryValue {
            switch k {
            case "access_token":
                self.accessToken = v as String
            case "token_type":
                self.tokenType = v as String
            case "expires_in":
                if let interval = (v as String).toInt() {
                    self.expiryDate = NSDate(timeIntervalSinceNow: NSTimeInterval(interval))
                }
            default:
                () // noop
            }
        }
    }

    required init(coder: NSCoder) {
        accessToken  = coder.decodeObjectForKey("accessToken") as String
        expiryDate   = coder.decodeObjectForKey("expiryDate") as NSDate
        tokenType    = coder.decodeObjectForKey("tokenType") as String
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(accessToken,  forKey: "accessToken")
        coder.encodeObject(expiryDate, forKey: "expiryDate")
        coder.encodeObject(tokenType, forKey: "tokenType")
    }
}
