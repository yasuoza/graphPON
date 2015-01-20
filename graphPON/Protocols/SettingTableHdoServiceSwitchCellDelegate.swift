import UIKit

@objc protocol SettingTableHdoServiceSwitchCellDelegate {
    func couponSwitchButtonValueDidChanged(switchButton:UISwitch, buttonCell: UITableViewCell)
}