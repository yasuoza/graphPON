import UIKit
import XCTest

class OAuth2ClientTests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Cleanup exisiting OAuth credential
        OAuth2Credential.restoreCredential()?.destroy()
    }

    override func tearDown() {
        // Cleanup exisiting OAuth credential
        OAuth2Credential.restoreCredential()?.destroy()

        super.tearDown()
    }

    func testParseQuery() {
        let dict = OAuth2Client.parseQuery("a=b&c=d&encoded=http%3A%2F%2Fexample.com")
        XCTAssertEqual(dict!, ["a": "b", "c": "d", "encoded": "http://example.com"], "hello")
    }

    func testInitWithoutExistingOAuthCredential() {
        let client = OAuth2Client()
        XCTAssertEqual(client.iijDeveloperID, "YOUR DEVLOPER ID HERE")
        XCTAssertEqual(client.iijOAuthCallbackURI, NSURL(string: "app://your_callback_uri_here")!)
        switch client.state {
        case OAuth2Client.AuthorizationState.UnAuthorized:
            break
        default:
            XCTFail("client state should be UnAuthorized")
        }
    }

    func testInitWitExistingOAuthCredential() {
        let cred = OAuth2Credential(dictionary: ["access_token": "at"])
        cred.save()
        let client = OAuth2Client()
        XCTAssertEqual(client.iijDeveloperID, "YOUR DEVLOPER ID HERE")
        XCTAssertEqual(client.iijOAuthCallbackURI, NSURL(string: "app://your_callback_uri_here")!)
        switch client.state {
        case let OAuth2Client.AuthorizationState.Authorized(credential):
            XCTAssertEqual(credential.accessToken!, "at")
        default:
            XCTFail("client state should be Authorized")
        }
    }

    func testAuthorize() {
        let client = OAuth2Client()
        XCTAssertNil(client.credential)
        let cred = OAuth2Credential(dictionary: ["access_token": "at"])
        client.authorized(credential: cred)
        XCTAssertEqual(client.credential!, cred)
        switch client.state {
        case let OAuth2Client.AuthorizationState.Authorized(credential):
            XCTAssertEqual(credential.accessToken!, "at")
        default:
            XCTFail("client state should be Authorized")
        }
    }

    func testDeauthorized() {
        let client = OAuth2Client()
        XCTAssertNil(client.credential)
        let cred = OAuth2Credential(dictionary: ["access_token": "at"])
        client.authorized(credential: cred)
        XCTAssertEqual(client.credential!, cred)
        client.deauthorize()
        XCTAssertNil(client.credential)
        switch client.state {
        case OAuth2Client.AuthorizationState.UnAuthorized:
            break
        default:
            XCTFail("client state should be UnAuthorized")
        }
    }

    func testPostOAuthDidAuthorizeNotificationWhenAuthorizationStatusDidChange() {
        let client = OAuth2Client()
        self.expectationForNotification(
            OAuth2Client.OAuthDidAuthorizeNotification,
            object: nil,
            handler: { notification  in
                return true
        })
        let cred = OAuth2Credential(dictionary: ["access_token": "at"])
        client.authorized(credential: cred)
        self.waitForExpectationsWithTimeout(1, handler: nil)
    }
    
}
