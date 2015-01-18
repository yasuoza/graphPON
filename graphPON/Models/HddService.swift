import UIKit

class HddService: NSObject {
    private(set) var hddServiceCode: String!
    private(set) var hdoServices: [HdoService]?
    var hdoServiceCodes: [String] {
        get {
            if let hdoService = hdoServices {
                return hdoService.reduce([], combine: { (var arr, hdoInfo) -> [String] in
                    return arr + [hdoInfo.hdoServiceCode]
                })
            } else {
                return []
            }
        }
    }

    init(hddServiceCode: String, hdoInfos: [HdoService]) {
        self.hddServiceCode = hddServiceCode
        self.hdoServices = hdoInfos
    }

    func hdoServiceForServiceCode(hdoServiceCode: String) -> HdoService? {
        if let hdoServiceIndex = find(self.hdoServiceCodes, hdoServiceCode) {
            return self.hdoServices?[hdoServiceIndex]
        }
        return nil
    }
}