import WatchKit
import Foundation


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
