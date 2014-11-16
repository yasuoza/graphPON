import UIKit

class AreaChartViewController: BaseChartViewController, JBLineChartViewDelegate, JBLineChartViewDataSource, ChartViewControllerProtocol {

    enum Mode {
        case Line, Bar, Area

        mutating func backgroundColor() -> UIColor {
            var hex: String
            switch self {
            case .Line:
                hex = "a7e3e0"
            case .Bar:
                hex = "ca9asc"
            case .Area:
                hex = "4fa9fa"
            }
            return UIColor(hex: hex)
        }

        mutating func titleText() -> String {
            switch self {
            case .Line:
                return "Line Chart"
            case .Bar:
                return "Bar Chart"
            case .Area:
                return "Area Chart"
            }
        }
    }

    @IBOutlet weak var chartViewContainerView: ChartViewContainerView!

    var mode: Mode = .Line

    private let kJBLineChartViewControllerChartPadding       = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeight        = CGFloat(250.0)
    private let kJBAreaChartViewControllerChartPadding       = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeaderHeight  = CGFloat(75.0)
    private let kJBAreaChartViewControllerChartHeaderPadding = CGFloat(20.0)
    private let kJBAreaChartViewControllerChartFooterHeight  = CGFloat(20.0)
    private let kJBAreaChartViewControllerChartFooterPadding = CGFloat(5.0)
    private let kJBAreaChartViewControllerChartLineWidth     = CGFloat(2.0)
    private let kJBAreaChartViewControllerMaxNumChartPoints  = CGFloat(12)
    private let kJBLineChartViewControllerChartFooterHeight  = CGFloat(20)

    private var chartData: [CGFloat]!
    private var horizontalSymbols: [NSString]!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initFakeData()

        self.view.backgroundColor = self.mode.backgroundColor()
        self.navigationItem.title = self.mode.titleText()

        self.chartViewContainerView.chartView.delegate = self
        self.chartViewContainerView.chartView.dataSource = self

        self.chartViewContainerView.chartView.headerPadding = kJBAreaChartViewControllerChartHeaderPadding
        self.chartViewContainerView.chartView.footerPadding = kJBAreaChartViewControllerChartFooterPadding
        self.chartViewContainerView.chartView.backgroundColor = self.mode.backgroundColor()

        let footerView = LineChartFooterView(frame: CGRectMake(
            self.chartViewContainerView.chartView.frame.origin.x,
            ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5),
            self.chartViewContainerView.chartView.bounds.width,
            kJBLineChartViewControllerChartFooterHeight + kJBLineChartViewControllerChartPadding
            ))
        footerView.backgroundColor = UIColor.clearColor()
        footerView.leftLabel.text = self.horizontalSymbols.first
        footerView.leftLabel.textColor = UIColor.whiteColor()
        footerView.rightLabel.text = self.horizontalSymbols.last
        footerView.rightLabel.textColor = UIColor.whiteColor()
        footerView.sectionCount = self.largestLineData().count
        self.chartViewContainerView.chartView.footerView = footerView

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.chartViewContainerView.chartView.setState(JBChartViewState.Expanded, animated: true)
    }

    // MARK: - Private methods

    func initFakeData() {
        chartData = [29, 44, 89, 179, 251, 321, 411, 512, 625, 700, 734, 787, 841].map { CGFloat($0) }
        horizontalSymbols = (1...chartData.count).map { "x-\($0)" }
    }

    func largestLineData() -> NSArray {
        return self.chartData
    }


    // MARK: - JBLineChartViewDataSource

    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return 1
    }

    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(self.chartData.count)
    }

    func lineChartView(lineChartView: JBLineChartView!, smoothLineAtLineIndex lineIndex: UInt) -> Bool {
        return true
    }


    // MARK: - JBLineChartViewDelegate

    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return self.chartData[Int(horizontalIndex)]
    }

    func lineChartView(lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt, touchPoint: CGPoint) {
        self.setTooltipVisible(true, animated: true, touchPoint: touchPoint)
        self.tooltipView.setText(horizontalSymbols[Int(horizontalIndex)])
    }

    func didDeselectLineInLineChartView(lineChartView: JBLineChartView!) {
        self.setTooltipVisible(false, animated: true)
    }

    func lineChartView(lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.clearColor()
    }

    func lineChartView(lineChartView: JBLineChartView!, fillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(white: 1.0, alpha: 0.5)
    }

    func lineChartView(lineChartView: JBLineChartView!, selectionColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor.clearColor()
    }

    func lineChartView(lineChartView: JBLineChartView!, selectionFillColorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
        return UIColor(white: 1.0, alpha: 1.0)
    }

    // MARK: - ChartViewControllerProtocol

    override func chartView() -> JBChartView! {
        return self.chartViewContainerView.chartView
    }

}
