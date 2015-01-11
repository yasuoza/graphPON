import UIKit

class HddService: NSObject {
    private(set) var hddServiceCode: String!
    private(set) var hdoServices: [HdoService]?

    lazy var hdoServiceCodes: [String] = {
        if let hdoInfos = self.hdoServices {
            return hdoInfos.reduce([], combine: { (var arr, hdoInfo) -> [String] in
                return arr + [hdoInfo.hdoServiceCode]
            })
        } else {
            return []
        }
    }()

    init(hddServiceCode: String, hdoInfos: [HdoService]) {
        super.init()
        self.hddServiceCode = hddServiceCode
        self.hdoServices = hdoInfos
    }
}