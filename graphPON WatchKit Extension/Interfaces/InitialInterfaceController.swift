import WatchKit
import Foundation
import GraphPONDataKit


class InitialInterfaceController: WKInterfaceController {

    override init() {
        super.init()

        let rootControllers: [String]

        switch OAuth2Client.sharedClient.state {
        case .UnAuthorized:
            rootControllers = ["RequestLoginInterfaceController"]
        case .Authorized:
            rootControllers = [
                "SummaryChartInterfaceController",
                "DailyChartInterfaceController",
                "AvailabilityChartInterfaceController",
            ]
        }

        InitialInterfaceController.reloadRootControllersWithNames(rootControllers, contexts: nil)
    }

}
