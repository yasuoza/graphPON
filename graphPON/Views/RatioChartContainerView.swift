import UIKit
import XYDoughnutChart

class RatioChartContainerView: UIView {

    @IBOutlet weak var chartView: XYDoughnutChart!

    override func layoutSubviews() {
        super.layoutSubviews()

        self.chartView.reloadData(false)
    }

}
