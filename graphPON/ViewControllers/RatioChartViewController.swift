import UIKit

class RatioChartViewController: BaseChartViewController, XYDoughnutChartDelegate, XYDoughnutChartDataSource {

    @IBOutlet var ratioChartContainerView: RatioChartContainerView!

    let chartLabels = ["00000000000", "111111111111", "22222222222"]
    let slices = [20.0, 50.0, 30.0]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red:0.180, green:0.361, blue:0.573, alpha:1.000)

        self.ratioChartContainerView.chartView.dataSource = self;
        self.ratioChartContainerView.chartView.delegate = self;

        self.chartInformationView.setHidden(true, animated: true)
    }

    // MARK: - XYDoughnutChartDelegate

    func doughnutChart(doughnutChart: XYDoughnutChart!, didSelectSliceAtIndex index: UInt) {
        self.chartInformationView.setTitleText("\(self.chartLabels[Int(index)])")
        self.chartInformationView.setHidden(false, animated: true)

        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.informationValueLabelSeparatorView.alpha = 1.0
                let valueText = NSString(format: "%.01f", self.slices[Int(index)])
                self.valueLabel.text = "\(valueText)%"
                self.valueLabel.alpha = 1.0
            }, completion: nil)
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, didDeselectSliceAtIndex index: UInt) {
        self.chartInformationView.setHidden(true, animated: true)

        UIView.animateWithDuration(NSTimeInterval(kJBChartViewDefaultAnimationDuration) * 0.5,
            delay: 0.0,
            options: UIViewAnimationOptions.BeginFromCurrentState,
            animations: {
                self.valueLabel.alpha = 0.0
                self.informationValueLabelSeparatorView.alpha = 0.0
            }, completion: { [unowned self] finish in
                if finish {
//                    self.displayLatestTotalChartInformation()
                }
        })
    }

    // MARK: - XYDoughnutChartDataSource

    func numberOfSlicesInDoughnutChart(pieChart: XYDoughnutChart!) -> UInt {
        return UInt(slices.count);
    }

    func doughnutChart(doughnutChart: XYDoughnutChart!, valueForSliceAtIndex index: UInt) -> CGFloat {
        return CGFloat(self.slices[Int(index)]);
    }

}
