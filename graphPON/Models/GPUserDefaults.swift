import Foundation

class GPUserDefaults: NSObject {

    class var suiteName: String {
        struct SuiteStruct {
            private static let suiteName = NSBundle(forClass: GPUserDefaults.self)
                .objectForInfoDictionaryKey("GraphPonAppGroupID") as String
        }

        return SuiteStruct.suiteName
    }

    private class var defaults: NSUserDefaults {
        struct DefaultsStruct {
            private static let instance = NSUserDefaults(suiteName: GPUserDefaults.suiteName)
        }
        return DefaultsStruct.instance!
    }

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
        for key in dict.keys {
            sharedDefaults().setObject(dict[key], forKey: key as String)
            systemDefaults.removeObjectForKey(key as String)
        }
        sharedDefaults().setBool(true, forKey: userDefaultsAlreadyMigrated)
        defaults.synchronize()
        systemDefaults.synchronize()
    }

}
