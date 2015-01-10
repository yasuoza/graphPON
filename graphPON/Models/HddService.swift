import UIKit

class HddService: NSObject {
    private(set) var hddServiceCode: String!
    private(set) var hdoInfos: [HdoInfo]?

    init(hddServiceCode: String, hdoInfos: [HdoInfo]) {
        super.init()
        self.hddServiceCode = hddServiceCode
        self.hdoInfos = hdoInfos
    }
}