import UIKit

class SettingTableHdoServiceSwitchCell: UITableViewCell {
    @IBOutlet weak var switchButton: UISwitch!

    weak var delegate: SettingTableHdoServiceSwitchCellDelegate?

    @IBAction func switchButtonValueChanged(switchButton: UISwitch) {
        self.delegate?.couponSwitchButtonValueDidChanged(self, switchButton: switchButton)
    }

}
