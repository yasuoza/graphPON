import UIKit

class SettingTableHdoServiceSwitchCell: UITableViewCell {
    @IBOutlet weak var switchButton: UISwitch!

    weak var delegate: SettingTableHdoServiceSwitchCellDelegate?

    @IBAction func switchButtonValueChanged(sender: AnyObject) {
        var senderButton: AnyObject = sender
        var cell: UITableViewCell? = nil
        while cell == nil {
            if let cell = senderButton.superview as? UITableViewCell {
                self.delegate?.couponSwitchButtonValueDidChanged(sender as UISwitch, buttonCell: cell)
                break
            } else {
                senderButton = senderButton.superview!!
            }
        }
    }

}
