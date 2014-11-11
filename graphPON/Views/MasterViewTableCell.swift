import UIKit

class MasterViewTableCell: UITableViewCell {

    enum Mode {
        case LineChart, BarChar, AreaChart
    }

    var mode: Mode = .LineChart {
        didSet {
            var image : UIImage!
            switch mode {
            case .LineChart:
                image = UIImage(named: "icon-line-chart.png")
            case .BarChar:
                image = UIImage(named: "icon-bar-chart.png")
            case .AreaChart:
                image = UIImage(named: "icon-area-chart.png")
            }
            self.accessoryView = UIImageView(image: image)
        }
    }

}
