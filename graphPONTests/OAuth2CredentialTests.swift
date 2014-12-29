import UIKit
import XCTest

class OAuth2CredentialTests: XCTestCase {

    var credential: OAuth2Credential!
    let credentialDict: [String: String] = [
        "access_token": "accessToken",
        "token_type": "tokenType",
        "expires_in": "123456"
    ]

    override func setUp() {
        super.setUp()

        credential = OAuth2Credential(dictionary: credentialDict)
    }
    
    override func tearDown() {
        credential.destroy()
        credential = nil

        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(credential.accessToken!, credentialDict["access_token"]!)
        XCTAssertEqual(credential.tokenType!, credentialDict["token_type"]!)
        let expires_in = credentialDict["expires_in"]!.toInt()!
        let expected = NSDate(timeIntervalSinceNow: NSTimeInterval(expires_in)).timeIntervalSinceReferenceDate
        XCTAssertEqualWithAccuracy(credential.expiryDate!.timeIntervalSinceReferenceDate, expected, 0.001)
    }

    func testSave() {
        XCTAssert(credential.save())
    }

    func testOverrideSave() {
        let anotherCredential = OAuth2Credential(dictionary: credentialDict)
        XCTAssert(anotherCredential.save())
        XCTAssertEqual(anotherCredential.accessToken!, credentialDict["access_token"]!)
        XCTAssertEqual(anotherCredential.tokenType!, credentialDict["token_type"]!)
    }

    func testRestoreCredential() {
        credential.save()
        let restoredCrdtl = OAuth2Credential.restoreCredential()!
        XCTAssertEqual(restoredCrdtl.accessToken!, credentialDict["access_token"]!)
        XCTAssertEqual(restoredCrdtl.tokenType!, credentialDict["token_type"]!)
        let expires_in = credentialDict["expires_in"]!.toInt()!
        let expected = NSDate(timeIntervalSinceNow: NSTimeInterval(expires_in)).timeIntervalSinceReferenceDate
        XCTAssertEqualWithAccuracy(restoredCrdtl.expiryDate!.timeIntervalSinceReferenceDate, expected, 1.0)
    }

    func testDestroyEmptyCredential() {
        XCTAssertNil(OAuth2Credential.restoreCredential())
        XCTAssertFalse(credential.destroy())
        XCTAssertNil(OAuth2Credential.restoreCredential())
    }

    func testDestroyExistingCredential() {
        credential.save()
        XCTAssert(credential.destroy())
        XCTAssertNil(OAuth2Credential.restoreCredential())
    }

}
