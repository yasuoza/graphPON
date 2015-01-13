import UIKit
import XCTest

class HddServiceTests: XCTestCase {

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

}
