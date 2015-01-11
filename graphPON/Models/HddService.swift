import UIKit

class HddService: NSObject {
    private(set) var hddServiceCode: String!
    private(set) var hdoInfos: [HdoInfo]?

    lazy var hdoServiceCodes: [String] = {
        if let hdoInfos = self.hdoInfos {
            return hdoInfos.reduce([], combine: { (var arr, hdoInfo) -> [String] in
                return arr + [hdoInfo.hdoServiceCode]
            })
        } else {
            return []
        }
    }()

    init(hddServiceCode: String, hdoInfos: [HdoInfo]) {
        super.init()
        self.hddServiceCode = hddServiceCode
        self.hdoInfos = hdoInfos
    }
}