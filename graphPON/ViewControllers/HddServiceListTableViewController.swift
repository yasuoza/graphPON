import UIKit

class HddServiceListTableViewController: UITableViewController {

    private var services: [String] = []
    var selectedService: String = ""
    var mode: BaseLineChartViewController.Mode = .Summary
    weak var delegate: HddServiceListTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        switch self.mode {
        case .Summary, .Ratio:
            self.services = PacketInfoManager.sharedManager.hddServiceCodes()
        case .Daily:
            self.services = PacketInfoManager.sharedManager.hdoServiceNumbers()
        }
    }

    // MARK: - IBActions

    @IBAction func closeViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.mode == .Daily {
            return PacketInfoManager.sharedManager.hddServiceCodes().count ?? 1
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.services.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.mode == .Daily {
            return PacketInfoManager.sharedManager.hddServiceCodes()[section]
        }
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HddServiceCell", forIndexPath: indexPath) as UITableViewCell

        let serviceCode = self.services[indexPath.row]

        cell.textLabel?.text = serviceCode

        if self.selectedService == serviceCode {
            cell.selected = true
            cell.accessoryType = .Checkmark
            cell.textLabel?.textColor = GlobalTintColor
        } else {
            cell.selected = false
            cell.accessoryType = .None
            cell.textLabel?.textColor = UIColor.blackColor()
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true, completion: nil)
        delegate?.serviceDidSelectedSection(indexPath.section, row: indexPath.row)
    }

}
