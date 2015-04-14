import UIKit

struct Coupon {

    enum Switch: Int {
        case All = 0, On = 1, Off = 2

        func text() -> String {
            switch self {
            case .All:
                return NSLocalizedString("All", comment: "All")
            case .On:
                return NSLocalizedString("On", comment: "On")
            case .Off:
                return NSLocalizedString("Off", comment: "Off")
            }
        }
    }

    let volume: Int

}
