import Foundation

class GPUserDefaults: NSObject {

    static let suiteName = NSBundle(forClass: GPUserDefaults.self).objectForInfoDictionaryKey("GraphPonAppGroupID") as! String
    private static let defaults = NSUserDefaults(suiteName: suiteName)!

    class func sharedDefaults() -> NSUserDefaults {
        return defaults
    }

    class func migrateFromOldDefaultsIfNeeded() {
        let userDefaultsAlreadyMigrated = "GPUserDefaultsAlreadyMigrated"

        if sharedDefaults().boolForKey(userDefaultsAlreadyMigrated) {
            return
        }

        let domain = NSBundle.mainBundle().bundleIdentifier!
        let systemDefaults = NSUserDefaults.standardUserDefaults()
        let dict = systemDefaults.persistentDomainForName(domain)!
        for origKey in dict.keys {
            let key = String(_cocoaString: origKey)
            sharedDefaults().setObject(dict[origKey], forKey: key)
            systemDefaults.removeObjectForKey(key)
        }
        sharedDefaults().setBool(true, forKey: userDefaultsAlreadyMigrated)
        defaults.synchronize()
        systemDefaults.synchronize()
    }

}
