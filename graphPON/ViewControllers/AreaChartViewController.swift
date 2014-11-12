import UIKit

class AreaChartViewController: BaseChartViewController, JBLineChartViewDelegate, JBLineChartViewDataSource {

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

    @IBOutlet weak var lineChartView: JBLineChartView!

    var mode: Mode = .Line

    private let kJBLineChartViewControllerChartPadding       = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeight        = CGFloat(250.0)
    private let kJBAreaChartViewControllerChartPadding       = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeaderHeight  = CGFloat(75.0)
    private let kJBAreaChartViewControllerChartHeaderPadding = CGFloat(20.0)
    private let kJBAreaChartViewControllerChartFooterHeight  = CGFloat(20.0)
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

        self.lineChartView.delegate = self
        self.lineChartView.dataSource = self
        self.lineChartView.headerPadding = kJBAreaChartViewControllerChartHeaderPadding
        self.lineChartView.backgroundColor = self.mode.backgroundColor()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let footerView = LineChartFooterView(frame: CGRectMake(
            self.lineChartView.frame.origin.x,
            ceil(self.view.bounds.size.height * 0.5) - ceil(kJBLineChartViewControllerChartFooterHeight * 0.5),
            self.lineChartView.bounds.width,
            kJBLineChartViewControllerChartFooterHeight + kJBLineChartViewControllerChartPadding
            ))
        footerView.backgroundColor = UIColor.clearColor()
        footerView.leftLabel.text = "left"
        footerView.leftLabel.textColor = UIColor.whiteColor()
        footerView.rightLabel.text = "right"
        footerView.rightLabel.textColor = UIColor.whiteColor()
        footerView.sectionCount = self.largestLineData().count
        self.lineChartView.footerView = footerView

        self.lineChartView.reloadData()
    }

    // MARK: - Private methods

    func initFakeData() {
        chartData = (1...30).map { CGFloat($0) }
        horizontalSymbols = (1...30).map { "x-\($0)" }
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


    // MARK: - JBLineChartViewDelegate

    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return self.chartData[Int(horizontalIndex)]
    }

}
