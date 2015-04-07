import WatchKit
import Foundation


class ServiceListInterfaceController: WKInterfaceController {

    @IBOutlet weak var serviceListTable: WKInterfaceTable!

    private var hddServiceCodes = [String]()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        PacketInfoManager.sharedManager.fetchLatestPacketLog(completion: { error in
            if error != nil {
                return
            }

            self.hddServiceCodes = PacketInfoManager.sharedManager.hddServiceCodes

            self.serviceListTable.setNumberOfRows(self.hddServiceCodes.count, withRowType: "default")
            let serviceCodeCount = self.hddServiceCodes.count
            for i in 0..<serviceCodeCount {
                let row = self.serviceListTable.rowControllerAtIndex(i) as ServiceListCellController
                row.serviceLabel.setText(self.hddServiceCodes[i])
            }
        })
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK: - WKInterfaceTable stack

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let context = ["serviceCode": self.hddServiceCodes[rowIndex]]
        self.pushControllerWithName("ChartInterfaceController", context: context)
    }

}
