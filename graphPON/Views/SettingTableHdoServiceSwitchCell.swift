import UIKit

class SettingTableHdoServiceSwitchCell: UITableViewCell {
    @IBOutlet weak var switchButton: UISwitch!

    weak var delegate: SettingTableHdoServiceSwitchCellDelegate?

    @IBAction func switchButtonValueChanged(switchButton: UISwitch) {
        var senderButton: AnyObject = switchButton
        var cell: UITableViewCell? = nil
        while cell == nil {
            if let cell = senderButton.superview as? UITableViewCell {
                self.delegate?.couponSwitchButtonValueDidChanged(switchButton, buttonCell: cell)
                break
            } else {
                senderButton = senderButton.superview!!
            }
        }
    }

}
