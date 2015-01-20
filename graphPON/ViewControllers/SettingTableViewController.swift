import UIKit

class SettingTableViewController: UITableViewController, SettingTableHdoServiceSwitchCellDelegate {

    private var couponUseDict: [String : Bool] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.enabled = false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 7 // 3 * 2 + 1
        }
        return 4 // 3 * 1 + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHddServiceNicknameCell", forIndexPath: indexPath) as UITableViewCell
            cell.detailTextLabel?.text = "My sweet family"
            return cell
        } else if (indexPath.row - 1) % 2 == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHdoServiceNicknameCell", forIndexPath: indexPath) as UITableViewCell
            cell.detailTextLabel?.text = "080-1234-5678"
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHdoServiceSwitchCell", forIndexPath: indexPath) as SettingTableHdoServiceSwitchCell
            cell.textLabel?.text = "Coupon"
            cell.delegate = self
            return cell
        }
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "hdd8080123-\(section)"
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
            cell.detailTextLabel?.text = nicknameTextField.text
        }
        saveAction.enabled = false
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = cell.detailTextLabel?.text
            NSNotificationCenter.defaultCenter().addObserverForName(
                UITextFieldTextDidChangeNotification,
                object: textField,
                queue: NSOperationQueue.mainQueue()) { (_) in
                saveAction.enabled = textField.text != ""
            }
        }

        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)

        self.presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - SettingTableHdoServiceSwitchCellDelegate

    func couponSwitchButtonValueDidChanged(switchButton: UISwitch, buttonCell: UITableViewCell) {
        if let indexPath = self.tableView.indexPathForCell(buttonCell) {
            let hdoService = "hdoServiceIndex#\((indexPath.row - 2) / 2)"
            if self.couponUseDict.removeValueForKey(hdoService) == nil {
                self.couponUseDict[hdoService] = switchButton.on
            }
            self.navigationItem.rightBarButtonItem?.enabled = !self.couponUseDict.keys.isEmpty
        }
    }

}
