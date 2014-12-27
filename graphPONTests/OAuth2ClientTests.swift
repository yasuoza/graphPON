import UIKit
import XCTest

class OAuth2ClientTests: XCTestCase {

    func testParseQuery() {
        let dict = OAuth2Client.parseQuery("a=b&c=d&encoded=http%3A%2F%2Fexample.com")
        XCTAssertEqual(dict!, ["a": "b", "c": "d", "encoded": "http://example.com"], "hello")
    }

    func testInit() {
        let client = OAuth2Client()
        XCTAssertEqual(client.iijDeveloperID, "YOUR DEVLOPER ID HERE")
    }
    
}
