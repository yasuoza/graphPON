import UIKit
import XCTest

class GPUserDefaultsTests: XCTestCase {

    override func tearDown() {
        let sharedDefaults = GPUserDefaults.sharedDefaults()
        sharedDefaults.setBool(false, forKey: "GPUserDefaultsAlreadyMigrated")
        for key in sharedDefaults.dictionaryRepresentation().keys {
            sharedDefaults.removeObjectForKey(String(_cocoaString: key))
        }
        sharedDefaults.synchronize()

        super.tearDown()
    }

    func testSuiteNameLoadsFromInfoPlist() {
        let suiteName = GPUserDefaults.suiteName
        XCTAssertEqual(suiteName, "group.com.yourcompany.app")
    }

    func testMigrateFromOldDefaultsIfNeeded() {
        let systemDefaults = NSUserDefaults.standardUserDefaults()
        let sharedDefaults = GPUserDefaults.sharedDefaults()
        let key = "testKey"
        let val = "testValue"

        systemDefaults.setObject(val, forKey: key)
        XCTAssertNil(sharedDefaults.valueForKey(key))

        GPUserDefaults.migrateFromOldDefaultsIfNeeded()
        XCTAssertNil(systemDefaults.valueForKey(key))
        XCTAssertEqual(String(_cocoaString: sharedDefaults.valueForKey(key)!), val)
    }

}
