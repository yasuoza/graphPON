import Foundation
import Security

class OAuth2Credential: NSObject, NSCoding {
    private static let keychainServiceName = "com.iijmio.api"
    private static let keychainAttributes: [String: AnyObject] = [
        String(kSecClass): kSecClassGenericPassword,
        String(kSecAttrService): keychainServiceName,
    ]

    private(set) var accessToken: String? = ""
    private(set) var tokenType: String? = ""
    private(set) var expiryDate: NSDate? = NSDate()

    // MARK: - Singleton methods

    class func restoreCredential() -> OAuth2Credential? {
        var attrs = self.keychainAttributes
        attrs[kSecReturnAttributes as String!] = kCFBooleanTrue

        var copy: Unmanaged<AnyObject>? = nil
        if SecItemCopyMatching(attrs, &copy) == errSecSuccess  {
            let key = String(kSecAttrGeneric)
            if let dict = copy?.takeRetainedValue() as? NSDictionary,
                let data = dict[key] as? NSData {
                    return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? OAuth2Credential
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
        var attrs = self.dynamicType.keychainAttributes

        attrs[kSecAttrGeneric as! String] = NSKeyedArchiver.archivedDataWithRootObject(self)

        let status = SecItemAdd(attrs, nil)
        if status == errSecDuplicateItem {
            if OAuth2Credential.restoreCredential()?.destroy() == true {
                return SecItemAdd(attrs, nil) == errSecSuccess
            }
        }
        return status == errSecSuccess
    }

    func destroy() -> Bool {
        if !(SecItemDelete(self.dynamicType.keychainAttributes) == errSecSuccess) {
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
