import Foundation
import Security

public class OAuth2Credential: NSObject, NSCoding {
    private static let keychainServiceName = "com.iijmio.api"
    private static let keychainAttributes: [String: AnyObject] = [
        String(kSecClass): kSecClassGenericPassword,
        String(kSecAttrService): keychainServiceName,
    ]

    public private(set) var accessToken: String? = ""
    public private(set) var tokenType: String? = ""
    public private(set) var expireDate: NSDate? = NSDate()

    // MARK: - Singleton methods

    public class func restoreCredential() -> OAuth2Credential? {
        var attrs = self.keychainAttributes
        attrs[String(kSecReturnAttributes)] = kCFBooleanTrue

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

    public func destroy() -> Bool {
        var attrs = self.dynamicType.keychainAttributes

        if !(SecItemDelete(attrs) == errSecSuccess) {
            return false
        }

        self.accessToken = nil
        self.tokenType = nil
        self.expireDate = nil
        return true

    }

    // MARK: - NSCoding

    public required init(coder: NSCoder) {
        accessToken  = coder.decodeObjectForKey("accessToken") as? String
        tokenType    = coder.decodeObjectForKey("tokenType") as? String
        expireDate   = coder.decodeObjectForKey("expiryDate") as? NSDate
    }

    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(accessToken,  forKey: "accessToken")
        coder.encodeObject(tokenType, forKey: "tokenType")
        coder.encodeObject(expireDate, forKey: "expiryDate")
    }

}
