import UIKit
import XCTest

class HdoServiceTests: XCTestCase {

    var hdoService: HdoService!
    var logLastMonth: PacketLog!
    var logToday: PacketLog!

    override func setUp() {
        super.setUp()

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var comps = calendar.components(
            (NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay),
            fromDate: NSDate()
        )
        comps.month = comps.month - 1
        logLastMonth = PacketLog(date: calendar.dateFromComponents(comps)!, withCoupon: 0, withoutCoupon: 0)
        logToday = PacketLog(date: NSDate(), withCoupon: 0, withoutCoupon: 0)
        hdoService = HdoService(
            hdoServiceCode: "hdoServiceCode",
            number: "080-1234-5678"
        )
        hdoService.packetLogs = [logLastMonth, logToday]
    }

    override func tearDown() {
        GPUserDefaults.sharedDefaults().removeObjectForKey("hdoServiceCode:nickName")

        super.tearDown()
    }

    func testPacketLogsInThisMonth() {
        XCTAssertEqual(hdoService.duration, HdoService.Duration.InThisMonth)
        XCTAssertEqual(hdoService.packetLogs.map { $0.date }, [logToday.date])
    }

    func testPacketLogsInLast30Days() {
        hdoService.duration = .InLast30Days
        XCTAssertEqual(hdoService.duration, HdoService.Duration.InLast30Days)
        XCTAssertEqual(hdoService.packetLogs.map { $0.date }, [logLastMonth.date, logToday.date])
    }

    func testInitWithNumber() {
        hdoService = HdoService(hdoServiceCode: "hdoServiceCode", number: "08012345678")
        XCTAssertEqual(hdoService.number, "080-1234-5678")
    }

    func testDefaultNicknameIsNumber() {
        hdoService = HdoService(hdoServiceCode: "hdoServiceCode", number: "08012345678")
        XCTAssertEqual(hdoService.nickName, "080-1234-5678")
    }

    func testSetNickname() {
        let nickName = "hello-nickname"
        hdoService.nickName = nickName
        XCTAssertEqual(hdoService.nickName, nickName)
    }

    func testRemoveNickname() {
        hdoService = HdoService(hdoServiceCode: "hdoServiceCode", number: "08012345678")
        hdoService.nickName = ""
        XCTAssertEqual(hdoService.nickName, "080-1234-5678")
    }

}
