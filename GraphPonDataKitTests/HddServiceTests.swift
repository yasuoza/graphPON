import UIKit
import XCTest

class HddServiceTests: XCTestCase {

    var oneMonthAgo: NSDate!
    var hdoService00: HdoService!
    var hdoService01: HdoService!

    override func setUp() {
        super.setUp()

        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        var comps = calendar.components(
            (NSCalendarUnit.CalendarUnitYear|NSCalendarUnit.CalendarUnitMonth|NSCalendarUnit.CalendarUnitDay),
            fromDate: NSDate()
        )
        comps.month = comps.month - 1
        oneMonthAgo = calendar.dateFromComponents(comps)!

        hdoService00 = HdoService(hdoServiceCode: "hdoServiceCode00", number: "080-1234-5678")
        hdoService00.packetLogs = [
            PacketLog(date: oneMonthAgo, withCoupon: 10, withoutCoupon: 5),
            PacketLog(date: NSDate().startDateOfMonth()!, withCoupon: 20, withoutCoupon: 10),
            PacketLog(date: NSDate(timeIntervalSinceNow: -(60 * 60 * 24)), withCoupon: 30, withoutCoupon: 15),
            PacketLog(date: NSDate(), withCoupon: 40, withoutCoupon: 20),
        ]

        hdoService01 = HdoService(hdoServiceCode: "hdoServiceCode01", number: "080-1234-5678")
        hdoService01.packetLogs = [
            PacketLog(date: oneMonthAgo, withCoupon: 20, withoutCoupon: 10),
            PacketLog(date: NSDate().startDateOfMonth()!, withCoupon: 40, withoutCoupon: 20),
            PacketLog(date: NSDate(timeIntervalSinceNow: -(60 * 60 * 24)), withCoupon: 60, withoutCoupon: 30),
            PacketLog(date: NSDate(), withCoupon: 80, withoutCoupon: 40),
        ]
    }

    override func tearDown() {
        GPUserDefaults.sharedDefaults().removeObjectForKey("hddServiceCode:nickName")

        super.tearDown()
    }

    func testHdoServiceCodes() {
        let hdoInfos: [HdoService] = [hdoService00, hdoService01]
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: hdoInfos)
        XCTAssertEqual(hddService.hdoServiceCodes, ["hdoServiceCode00", "hdoServiceCode01"])
    }

    func testHdoServiceForServiceCode() {
        let hdoInfos: [HdoService] = [hdoService00, hdoService01]
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: hdoInfos)
        XCTAssertEqual(hddService.hdoServiceForServiceCode("hdoServiceCode00")!, hdoInfos.first!)
    }

    func testSummarizeServiceUsageInDurationThisMonthWithCouponOn() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00])
        let summary = hddService.summarizeServiceUsageInDuration(.InThisMonth, couponSwitch: .On)
        XCTAssertEqual(summary, [[20.0, 50.0, 90.0]])
    }

    func testSummarizeServiceUsageInDurationThisMonthWithCouponOff() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00])
        let summary = hddService.summarizeServiceUsageInDuration(.InThisMonth, couponSwitch: .Off)
        XCTAssertEqual(summary, [[10.0, 25.0, 45.0]])
    }

    func testSummarizeServiceUsageInDurationInLast30DaysWithCouponOn() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00])
        let summary = hddService.summarizeServiceUsageInDuration(.InLast30Days, couponSwitch: .On)
        XCTAssertEqual(summary, [[10.0, 30.0, 60.0, 100.0]])
    }

    func testSummarizeServiceUsageInDurationInLast30DaysWithCouponOff() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00])
        let summary = hddService.summarizeServiceUsageInDuration(.InLast30Days, couponSwitch: .Off)
        XCTAssertEqual(summary, [[5.0, 15.0, 30.0, 50.0]])
    }

    func testSummarizeServiceUsageInDurationThisMonthWithCouponOnWithTotalSummary() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let summary = hddService.summarizeServiceUsageInDuration(.InThisMonth, couponSwitch: .On)
        XCTAssertEqual(summary, [[20.0, 50.0, 90.0], [40.0, 100.0, 180.0], [60.0, 150.0, 270.0]])
    }

    func testSummarizeServiceUsageInDurationThisMonthWithCouponOffWithTotalSummary() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let summary = hddService.summarizeServiceUsageInDuration(.InThisMonth, couponSwitch: .Off)
        XCTAssertEqual(summary, [[10.0, 25.0, 45.0], [20.0, 50.0, 90.0], [30.0, 75.0, 135.0]])
    }

    func testSummarizeServiceUsageInDurationInLast30DaysWithCouponOnWithTotalSummary() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let summary = hddService.summarizeServiceUsageInDuration(.InLast30Days, couponSwitch: .On)
        XCTAssertEqual(summary, [[10.0, 30.0, 60.0, 100.0], [20.0, 60.0, 120.0, 200.0], [30.0, 90.0, 180.0, 300.0]])
    }

    func testSummarizeServiceUsageInDurationInLast30DaysWithCouponOffWithTotalSummary() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let summary = hddService.summarizeServiceUsageInDuration(.InLast30Days, couponSwitch: .Off)
        XCTAssertEqual(summary, [[5.0, 15.0, 30.0, 50.0], [10.0, 30.0, 60.0, 100.0], [15.0, 45.0, 90.0, 150.0]])
    }

    func testDailyTotalUsageInDurationThisMonthWithCouponOn() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let totalUsage = hddService.dailyTotalUsageInDuration(.InThisMonth, couponSwitch: .On)
        XCTAssertEqual(totalUsage, [60.0, 90.0, 120.0])
    }

    func testDailyTotalUsageInDurationThisMonthWithCouponOff() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let totalUsage = hddService.dailyTotalUsageInDuration(.InThisMonth, couponSwitch: .Off)
        XCTAssertEqual(totalUsage, [30.0, 45.0, 60.0])
    }

    func testDailyTotalUsageInDurationInLast30DaysWithCouponOn() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let totalUsage = hddService.dailyTotalUsageInDuration(.InLast30Days, couponSwitch: .On)
        XCTAssertEqual(totalUsage, [30.0, 60.0, 90.0, 120.0])
    }

    func testDailyTotalUsageInDurationInLast30DaysWithCouponOff() {
        let hddService = HddService(hddServiceCode: "hddServiceCode", hdoServices: [hdoService00, hdoService01])
        let totalUsage = hddService.dailyTotalUsageInDuration(.InLast30Days, couponSwitch: .Off)
        XCTAssertEqual(totalUsage, [15.0, 30.0, 45.0, 60.0])
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
