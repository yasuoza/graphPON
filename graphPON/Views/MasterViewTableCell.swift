import UIKit

class MasterViewTableCell: UITableViewCell {

    enum Mode {
        case LineChart, BarChar, AreaChart

        mutating func textLabelText() -> NSString {
            var key: NSString!
            var fallback: NSString!
            switch self {
            case .LineChart:
                key = "label.average.daily.rainfall"
                fallback = "Average Daily Rainfall"
            case .BarChar:
                key = "label.metropolitan.average"
                fallback = "Metropolitan Average"
            case .AreaChart:
                key = "label.national.average"
                fallback = "National Average"
            }
            return NSLocalizedString(key, tableName: nil, bundle: NSBundle.mainBundle(), value: fallback, comment: "")
        }

        mutating func detailLabelText() -> NSString {
            var key: NSString!
            var fallback: NSString!
            switch self {
            case .LineChart:
                key = "label.san.francisco.2013"
                fallback = "San Francisco - 2013"
            case .BarChar:
                key = "label.worldwide.2012"
                fallback = "Worldwide - 2012"
            case .AreaChart:
                key = "label.worldwide.2011"
                fallback = "Worldwide - 2011"
            }
            return NSLocalizedString(key, tableName: nil, bundle: NSBundle.mainBundle(), value: fallback, comment: "")
        }
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
