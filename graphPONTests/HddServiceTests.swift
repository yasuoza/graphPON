import UIKit
import XCTest

class HddServiceTests: XCTestCase {

    override func tearDown() {
        GPUserDefaults.sharedDefaults().removeObjectForKey("hddServiceCode:nickName")

        super.tearDown()
    }

    func testHdoServiceCodes() {
        let hdoService00 = HdoService(hdoServiceCode: "hdoServiceCode00", number: "080-1234-5678")
        hdoService00.packetLogs = []

        let hdoService01 = HdoService(hdoServiceCode: "hdoServiceCode01", number: "080-1234-5678")
        hdoService01.packetLogs = []

        let hdoInfos = [hdoService00, hdoService01]

        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: hdoInfos)
        XCTAssertEqual(hddService.hdoServiceCodes, ["hdoServiceCode00", "hdoServiceCode01"])
    }

    func testHdoServiceForServiceCode() {
        let hdoService00 = HdoService(hdoServiceCode: "hdoServiceCode00", number: "080-1234-5678")
        hdoService00.packetLogs = []

        let hdoService01 = HdoService(hdoServiceCode: "hdoServiceCode01", number: "080-1234-5678")
        hdoService01.packetLogs = []

        let hdoInfos = [hdoService00, hdoService01]

        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: hdoInfos)
        XCTAssertEqual(hddService.hdoServiceForServiceCode("hdoServiceCode00")!, hdoInfos.first!)
    }

    func testDefaultNicknameIsNumber() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", coupons: [], hdoServices: [])
        XCTAssertEqual(hddService.nickName, "hddServiceCode")
    }

    func testSetNickname() {
        let nickName = "hello-nickname"
        let hddService = HddService(hddServiceCode: "hddServiceCode", coupons: [], hdoServices: [])
        hddService.nickName = nickName
        XCTAssertEqual(hddService.nickName, nickName)
    }

    func testRemoveNickname() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", coupons: [], hdoServices: [])
        hddService.nickName = ""
        XCTAssertEqual(hddService.nickName, "hddServiceCode")
    }

}
