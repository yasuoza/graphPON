import UIKit

class AreaChartViewController: BaseChartViewController, JBLineChartViewDelegate, JBLineChartViewDataSource {

    private let kJBLineChartViewControllerChartPadding = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeight = CGFloat(250.0)
    private let kJBAreaChartViewControllerChartPadding = CGFloat(10.0)
    private let kJBAreaChartViewControllerChartHeaderHeight = CGFloat(75.0)
    private let kJBAreaChartViewControllerChartHeaderPadding = CGFloat(20.0)
    private let kJBAreaChartViewControllerChartFooterHeight = CGFloat(20.0)
    private let kJBAreaChartViewControllerChartLineWidth = CGFloat(2.0)
    private let kJBAreaChartViewControllerMaxNumChartPoints = CGFloat(12)

    private var chartData: [CGFloat]!
    private var horizontalSymbols: [NSString]!

    @IBOutlet weak var lineChartView: JBLineChartView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initFakeData()

        self.view.backgroundColor = self.colorWithHexString("b7e3e4")

        self.lineChartView.delegate = self
        self.lineChartView.dataSource = self
        self.lineChartView.headerPadding = kJBAreaChartViewControllerChartHeaderPadding
        self.lineChartView.backgroundColor = self.colorWithHexString("b7e3e4")

        self.lineChartView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.lineChartView.setState(JBChartViewState.Expanded, animated:true)
    }

    // MARK: - Private methods

    func initFakeData() {
        chartData = (1...30).map { CGFloat($0) }
        horizontalSymbols = (1...30).map { "x-\($0)" }
    }

    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString

        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }

        if (countElements(cString) != 6) {
            return UIColor.grayColor()
        }

        var rString = (cString as NSString).substringToIndex(2)
        var gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        var bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)

        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)

        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }


    // MARK: - JBLineChartViewDataSource

    func numberOfLinesInLineChartView(lineChartView: JBLineChartView!) -> UInt {
        return UInt(self.chartData.count)
    }

    func lineChartView(lineChartView: JBLineChartView!, numberOfVerticalValuesAtLineIndex lineIndex: UInt) -> UInt {
        return UInt(self.chartData.count)
    }


    // MARK: - JBLineChartViewDelegate

    func lineChartView(lineChartView: JBLineChartView!, verticalValueForHorizontalIndex horizontalIndex: UInt, atLineIndex lineIndex: UInt) -> CGFloat {
        return self.chartData[Int(horizontalIndex)]
    }

}
