import UIKit

class ChartViewContainerView: UIView {

    @IBOutlet weak var chartView: JBChartView!

    override func layoutSubviews() {
        super.layoutSubviews()

        self.chartView.reloadData()
    }

    func reloadChartData() {
        self.chartView.reloadData()
    }

}
