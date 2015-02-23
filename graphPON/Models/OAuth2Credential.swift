import Foundation
import Security

class OAuth2Credential: NSObject, NSCoding {
    private(set) var accessToken: String? = ""
    private(set) var tokenType: String? = ""
    private(set) var expiryDate: NSDate? = NSDate()

    struct AccountStore {
        private static let serviceName = "com.iijmio.api"

        static let attributes: [String: AnyObject] = [
            (kSecClass as! String): kSecClassGenericPassword,
            (kSecAttrService as! String): serviceName,
        ]
    }

    // MARK: - Singleton methods

    class func restoreCredential() -> OAuth2Credential? {
        var attrs = AccountStore.attributes
        attrs[kSecReturnAttributes as! String] = kCFBooleanTrue

        // http://stackoverflow.com/a/27721235/1427595
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { SecItemCopyMatching(attrs, UnsafeMutablePointer($0)) }

        if status == errSecSuccess {
            if let dict = result as? NSDictionary {
                let key = String(kSecAttrGeneric)
                if let data = dict[key] as? NSData {
                    return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? OAuth2Credential
                }
            }
        }
        return nil
    }

    // MARK: - Instance methods

    init(dictionary dictionaryValue: [String: AnyObject]) {
        for (k, v) in dictionaryValue {
            switch k {
            case "access_token":
                self.accessToken = v as? String
            case "token_type":
                self.tokenType = v as? String
            case "expires_in":
                if let interval = (v as? String)?.toInt() {
                    self.expiryDate = NSDate(timeIntervalSinceNow: NSTimeInterval(interval))
                }
            default:
                break
            }
        }
    }

    func save() -> Bool {
        var attrs = AccountStore.attributes

        attrs[kSecAttrGeneric as! String] = NSKeyedArchiver.archivedDataWithRootObject(self)

        let status = SecItemAdd(attrs, nil)
        if status == OSStatus(errSecDuplicateItem) {
            if OAuth2Credential.restoreCredential()?.destroy() == true {
                return SecItemAdd(attrs, nil) == OSStatus(errSecSuccess)
            }
        }
        return status == OSStatus(errSecSuccess)
    }

    func destroy() -> Bool {
        if !(SecItemDelete(AccountStore.attributes) == OSStatus(errSecSuccess)) {
            return false
        }

        self.accessToken = nil
        self.tokenType = nil
        self.expiryDate = nil
        return true

    }

    // MARK: - NSCoding

    required init(coder: NSCoder) {
        accessToken  = coder.decodeObjectForKey("accessToken") as? String
        tokenType    = coder.decodeObjectForKey("tokenType") as? String
        expiryDate   = coder.decodeObjectForKey("expiryDate") as? NSDate
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(accessToken,  forKey: "accessToken")
        coder.encodeObject(tokenType, forKey: "tokenType")
        coder.encodeObject(expiryDate, forKey: "expiryDate")
    }

}
