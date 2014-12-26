import Foundation

class OAuth2AccountStore: NSObject {
    let serviceName: String!

    init(serviceName: String) {
        self.serviceName = serviceName
    }

    private var attributes: [String: AnyObject] {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: self.serviceName,
        ]
    }

    func queryCredential() -> OAuth2Credential? {
        var attrs = attributes
        attrs[kSecReturnAttributes] = kCFBooleanTrue

        var copy: Unmanaged<AnyObject>? = nil
        if SecItemCopyMatching(attrs, &copy) == OSStatus(errSecSuccess)  {
            if let copy = copy? {
                let dict = copy.takeRetainedValue() as NSDictionary
                let key = String(kSecAttrGeneric)
                if let data = dict[key] as? NSData {
                    return NSKeyedUnarchiver.unarchiveObjectWithData(data) as OAuth2Credential?
                }
            }
        }
        return nil
    }

    func removeCredential() -> Bool {
        return SecItemDelete(attributes) == OSStatus(errSecSuccess)
    }

    func saveCredential(credential: OAuth2Credential) -> Bool {
        var attrs = attributes

        attrs[kSecAttrGeneric] = NSKeyedArchiver.archivedDataWithRootObject(credential)

        let status = SecItemAdd(attrs, nil)
        if status == OSStatus(errSecDuplicateItem) {
            if removeCredential() {
                return SecItemAdd(attrs, nil) == OSStatus(errSecSuccess)
            }
        }
        return status == OSStatus(errSecSuccess)
    }
   
}
