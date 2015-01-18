import UIKit
import XCTest

class HdoServiceTests: XCTestCase {

    var hdoService: HdoService!
    var logLastMonth: PacketLog!
    var logToday: PacketLog!

    override func setUp() {
        super.setUp()

        let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
        var comps = calendar.components(
            (NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay),
            fromDate: NSDate()
        )
        comps.month = comps.month - 1
        logLastMonth = PacketLog(date: calendar.dateFromComponents(comps)!, withCoupon: 0, withoutCoupon: 0)
        logToday = PacketLog(date: NSDate(), withCoupon: 0, withoutCoupon: 0)
        hdoService = HdoService(
            hdoServiceCode: "hdoServiceCode",
            packetLogs: [logLastMonth, logToday]
        )

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

}
