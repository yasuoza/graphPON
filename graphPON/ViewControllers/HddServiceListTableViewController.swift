import UIKit

class HddServiceListTableViewController: UITableViewController {

    var selectedService: String = ""
    var mode: BaseChartViewController.Mode = .Summary
    weak var delegate: HddServiceListTableViewControllerDelegate?
    private var serviceCodes: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        switch self.mode {
        case .Summary, .Ratio, .Availability:
            self.serviceCodes = PacketInfoManager.sharedManager.hddServiceCodes
        case .Daily:
            self.serviceCodes = PacketInfoManager.sharedManager.hdoServiceNumbers
        }
    }

    // MARK: - IBActions

    @IBAction func closeViewController() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.mode == .Daily {
            return PacketInfoManager.sharedManager.hddServiceCodes.count ?? 0
        }
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.mode {
        case .Summary, .Ratio, .Availability:
            return PacketInfoManager.sharedManager.hddServiceCodes.count
        case .Daily:
            return PacketInfoManager.sharedManager.hddServices[section].hdoServices?.count ?? 0
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.mode == .Daily {
            return PacketInfoManager.sharedManager.hddServices[section].nickName
        }
        return nil
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HddServiceCell", forIndexPath: indexPath) as! UITableViewCell

        switch self.mode {
        case .Summary, .Ratio, .Availability:
            cell.textLabel?.text = PacketInfoManager.sharedManager.hddServices[indexPath.row].nickName
        case .Daily:
            cell.textLabel?.text = PacketInfoManager.sharedManager.hddServices[indexPath.section].hdoServices?[indexPath.row].nickName
        }

        let serviceCode = self.serviceCodes[indexPath.row]
        if serviceCode == self.selectedService {
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
