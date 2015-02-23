import UIKit
import Alamofire
import SwiftyJSON

class SettingTableViewController: UITableViewController, SettingTableHdoServiceSwitchCellDelegate, PromptLoginPresenter, ErrorAlertPresenter {

    private var couponUseDict: [String: Bool] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem?.enabled = false

        NSNotificationCenter.defaultCenter().addObserverForName(
            PacketInfoManager.LatestPacketLogsDidFetchNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { _ in
                self.tableView.reloadData()
        })
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationDidBecomeActiveNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { _ in
                self.presentPromptLoginControllerIfNeeded()
        })

        switch OAuth2Client.sharedClient.state {
        case .UnAuthorized:
            self.presentPromptLoginControllerIfNeeded()
        default:
            break
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Actions

    @IBAction func saveButtonTaped(sender: AnyObject) {
        if self.couponUseDict.keys.isEmpty {
            self.navigationItem.rightBarButtonItem?.enabled = false
            return
        }

        let params: [[String: AnyObject]] = couponUseDict.keys.array.map { key in
            return [
                "hdoServiceCode": key,
                "couponUse": self.couponUseDict[key]!
            ]
        }

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        Alamofire.request(OAuth2Router.PutCoupon(params))
            .responseJSON { (_, response, json, error) in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                if let error = error {
                    self.presentErrorAlertController(error)
                    return
                }

                let json = JSON(json!)

                switch response!.statusCode {
                case 403:
                    OAuth2Client.sharedClient.deauthorize()
                    self.presentPromptLoginControllerIfNeeded()
                    return
                case 429:
                    let apiError = NSError(
                        domain: OAuth2Router.APIErrorDomain,
                        code: OAuth2Router.TooManyRequestErrorCode,
                        userInfo: ["resultCode": json["resultCode"].stringValue]
                    )
                    self.presentErrorAlertController(apiError)
                    return
                case 400...503:
                    let apiError = NSError(
                        domain: OAuth2Router.APIErrorDomain,
                        code: OAuth2Router.UnknownErrorCode,
                        userInfo: ["resultCode": json["resultCode"].stringValue]
                    )
                    self.presentErrorAlertController(apiError)
                    return
                default:
                    break
                }

                self.couponUseDict = [:]
                self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }

    // MARK: - PromptLoginPresenter

    func presentPromptLoginControllerIfNeeded() {
        switch OAuth2Client.sharedClient.state {
        case OAuth2Client.AuthorizationState.UnAuthorized:
            if let _ = self.presentedViewController as? PromptLoginController {
                break
            }
            return self.presentViewController(
                PromptLoginController.alertController(),
                animated: true,
                completion: nil
            )
        default:
            break
        }
    }

    // MARK: - ErrorAlertPresenter

    func presentErrorAlertController(error: NSError) {
        self.presentViewController(
            ErrorAlertController.initWithError(error),
            animated: true,
            completion: nil
        )
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return PacketInfoManager.sharedManager.hddServices.count + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == numberOfSectionsInTableView(tableView) - 1 {
            return 1
        }
        return 1 + 2 * (PacketInfoManager.sharedManager.hddServices[section].hdoServices?.count ?? 0)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Logout cell
        if indexPath.section == self.numberOfSectionsInTableView(tableView) - 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableServiceLogoutCell", forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = NSLocalizedString("Logout", comment: "Logout from service")
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = GlobalTintColor
            return cell
        }

        // Service cells
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHddServiceNicknameCell", forIndexPath: indexPath) as! UITableViewCell
            cell.detailTextLabel?.text = PacketInfoManager.sharedManager.hddServices[indexPath.section].nickName
            return cell
        } else if (indexPath.row - 1) % 2 == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHdoServiceNicknameCell", forIndexPath: indexPath) as! UITableViewCell
            let hdoNickname = PacketInfoManager.sharedManager.hddServices[indexPath.section].hdoServices?[(indexPath.row - 1) / 2 ].nickName
            cell.detailTextLabel?.text = hdoNickname
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("SettingTableHdoServiceSwitchCell", forIndexPath: indexPath) as! SettingTableHdoServiceSwitchCell
            cell.textLabel?.text = NSLocalizedString("UseCoupon", comment: "Use coupon or not in setting table cell")
            cell.textLabel?.backgroundColor = UIColor.clearColor()
            cell.delegate = self

            if let hdoService = PacketInfoManager.sharedManager.hddServices[indexPath.section].hdoServices?[(indexPath.row - 2) / 2] {
                cell.switchButton.on = hdoService.couponUse
            }

            return cell
        }
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == numberOfSectionsInTableView(tableView) - 1 {
            return nil
        }
        return PacketInfoManager.sharedManager.hddServices[section].hddServiceCode
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Disable coupon cell selection
        if indexPath.row > 0 && indexPath.row % 2 == 0 {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.selected = false
            }
            return nil
        }
        return indexPath
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        cell.selected = false

        // Logout action
        if indexPath.section == numberOfSectionsInTableView(tableView) - 1 {
            let alertController = UIAlertController(
                title: NSLocalizedString("AreYouSureToLogout?", comment: "Logout confirm alert title text"),
                message: NSLocalizedString("ToLogoutFromServiceTapLogoutButton", comment: "Logout confirm alert message text"),
                preferredStyle: UIAlertControllerStyle.Alert
            )
            let logoutAction = UIAlertAction(title: "Logout", style: .Default, handler: { (_) in
                OAuth2Client.sharedClient.deauthorize()
                OAuth2Credential.restoreCredential()?.destroy()
                OAuth2Client.sharedClient.openOAuthAuthorizeURL()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(logoutAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }

        // Save nickname action
        let alertController = UIAlertController(title: "Nickname", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (_) in
            let nicknameTextField = alertController.textFields![0] as! UITextField
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.clearButtonMode = .WhileEditing
            textField.autocapitalizationType = .Words
            textField.text = cell.detailTextLabel?.text
            if indexPath.row == 0 {
                let hddService = PacketInfoManager.sharedManager.hddServices[indexPath.section]
                textField.placeholder = hddService.hddServiceCode
            } else {
                if let hdoService = PacketInfoManager.sharedManager.hddServices[indexPath.section].hdoServices?[(indexPath.row - 1) / 2] {
                    textField.placeholder = hdoService.number
                }
            }
        }

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

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
    }

}
