import UIKit
import XCTest

class HddServiceTests: XCTestCase {

    override func tearDown() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hddServiceCode:nickName")

        super.tearDown()
    }

    func testHdoServiceCodes() {
        let hdoInfos = [
            HdoService(hdoServiceCode: "hdoServiceCode00", packetLogs: []),
            HdoService(hdoServiceCode: "hdoServiceCode01", packetLogs: [])
        ]
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoInfos: hdoInfos)
        XCTAssertEqual(hddService.hdoServiceCodes, ["hdoServiceCode00", "hdoServiceCode01"])
    }

    func testHdoServiceForServiceCode() {
        let hdoInfos = [
            HdoService(hdoServiceCode: "hdoServiceCode00", packetLogs: []),
            HdoService(hdoServiceCode: "hdoServiceCode01", packetLogs: [])
        ]
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoInfos: hdoInfos)
        XCTAssertEqual(hddService.hdoServiceForServiceCode("hdoServiceCode00")!, hdoInfos.first!)
    }

    func testDefaultNicknameIsNumber() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", coupons: [], hdoInfos: [])
        XCTAssertEqual(hddService.nickName, "hddServiceCode")
    }

    func testSetNickname() {
        let nickName = "hello-nickname"
        let hddService = HddService(hddServiceCode: "hddServiceCode", coupons: [], hdoInfos: [])
        hddService.nickName = nickName
        XCTAssertEqual(hddService.nickName, nickName)
    }

    func testRemoveNickname() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", coupons: [], hdoInfos: [])
        hddService.nickName = ""
        XCTAssertEqual(hddService.nickName, "hddServiceCode")
    }

}
