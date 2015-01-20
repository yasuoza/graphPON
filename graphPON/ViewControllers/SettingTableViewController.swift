import UIKit

class SettingTableViewController: UITableViewController, SettingTableHdoServiceSwitchCellDelegate {

    private var couponUseDict: [String : Bool] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.enabled = false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return PacketInfoManager.sharedManager.hddServices.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + 2 * (PacketInfoManager.sharedManager.hddServices[section].hdoServices?.count ?? 0)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHddServiceNicknameCell", forIndexPath: indexPath) as UITableViewCell
            cell.detailTextLabel?.text = PacketInfoManager.sharedManager.hddServices[indexPath.section].nickName
            return cell
        } else if (indexPath.row - 1) % 2 == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHdoServiceNicknameCell", forIndexPath: indexPath) as UITableViewCell
            let hdoNickname = PacketInfoManager.sharedManager.hddServices[indexPath.section].hdoServices?[(indexPath.row - 1) / 2 ].nickName
            cell.detailTextLabel?.text = hdoNickname
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHdoServiceSwitchCell", forIndexPath: indexPath) as SettingTableHdoServiceSwitchCell
            cell.textLabel?.text = "Coupon Use"
            cell.delegate = self
            return cell
        }
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return PacketInfoManager.sharedManager.hddServices[section].hddServiceCode
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Disable coupon cell selection
        if indexPath.row > 0 && indexPath.row % 2 == 0 {
            return nil
        }
        return indexPath
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.selected = false

        let alertController = UIAlertController(title: "Nickname", message: nil, preferredStyle: UIAlertControllerStyle.Alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        let saveAction = UIAlertAction(title: "Save", style: .Default) { (_) in
            let nicknameTextField = alertController.textFields![0] as UITextField
            if indexPath.row == 0 {
                let hddService = PacketInfoManager.sharedManager.hddServices[indexPath.section]
                hddService.nickName = nicknameTextField.text
            } else {
                if let hdoService = PacketInfoManager.sharedManager.hddServices[indexPath.section].hdoServices?[(indexPath.row - 1) / 2] {
                    hdoService.nickName = nicknameTextField.text
                }
            }
            self.tableView.reloadData()
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = cell.detailTextLabel?.text
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - SettingTableHdoServiceSwitchCellDelegate

    func couponSwitchButtonValueDidChanged(switchButton: UISwitch, buttonCell: UITableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(buttonCell) {
            if let hdoService = PacketInfoManager.sharedManager.hddServices[indexPath.section].hdoServices?[(indexPath.row - 1) / 2] {
                let hdoServiceCode = hdoService.hdoServiceCode
                if self.couponUseDict.removeValueForKey(hdoServiceCode) == nil {
                    self.couponUseDict[hdoServiceCode] = switchButton.on
                }
                self.navigationItem.rightBarButtonItem?.enabled = !self.couponUseDict.keys.isEmpty
            }
        }
        println(self.couponUseDict)
    }

}
