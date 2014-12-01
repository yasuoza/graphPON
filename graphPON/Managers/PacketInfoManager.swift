import UIKit

class PacketInfoManager: NSObject {

    private var logInfo: [String: Array<PacketLog>]!

    class var sharedManager : PacketInfoManager {
        struct Static {
            static let instance : PacketInfoManager = PacketInfoManager()
        }
        return Static.instance
    }

    func fetchLatestData() {
        self.logInfo = ["hdo88134635": [
            PacketLog(date: NSDate(), withCoupon: 12, withoutCoupon: 0)
        ]]
    }

    func packetLogsServiceCode(serviceCode: String) -> Array<PacketLog>? {
        return self.logInfo[serviceCode]
    }
   
}
