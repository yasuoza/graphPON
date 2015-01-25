import UIKit

let kJBLineChartFooterViewSeparatorWidth          = CGFloat(0.5)
let kJBLineChartFooterViewSeparatorHeight         = CGFloat(3.0)
let kJBLineChartFooterViewSeparatorSectionPadding = CGFloat(1.0)
let kJBLineChartViewControllerChartPadding        = CGFloat(10.0)
let kJBLineChartViewControllerChartFooterHeight   = CGFloat(20)
let kJBAreaChartViewControllerChartHeight         = CGFloat(250.0)
let kJBAreaChartViewControllerChartPadding        = CGFloat(10.0)
let kJBAreaChartViewControllerChartHeaderHeight   = CGFloat(75.0)
let kJBAreaChartViewControllerChartHeaderPadding  = CGFloat(20.0)
let kJBAreaChartViewControllerChartFooterHeight   = CGFloat(20.0)
let kJBAreaChartViewControllerChartFooterPadding  = CGFloat(5.0)
let kJBAreaChartViewControllerChartLineWidth      = CGFloat(2.0)

class BaseChartViewController: UIViewController, StateRestorable {

    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var chartInformationView: ChartInformationView!
    @IBOutlet weak var informationValueLabelSeparatorView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var chartDurationSegmentControl: UISegmentedControl?

    var serviceCode: String?
    var chartDataFilteringSegment: ChartDataFilteringSegment = .All
    var chartDurationSegment: HdoService.Duration = .InThisMonth

    private var navBarHairlineImageView: UIImageView?
    private var restrationalServiceCodeIdentifier: String!
    private var restrationalDurationSegmentIdentifier: String!
    private var restrationalDataFilteringSegmentIdentifier: String!

    enum ChartDataFilteringSegment: Int {
        case All = 0, WithCoupon = 1, WithoutCoupon = 2

        func text() -> String {
            switch self {
            case .All:
                return "ALL"
            case .WithCoupon:
                return "ON"
            case .WithoutCoupon:
                return "OFF"
            }
        }
    }

    enum Mode {
        case Daily, Summary, Ratio, Availability

        func backgroundColor() -> UIColor {
            switch self {
            case .Daily:
                return UIColor(red:0.376, green:0.573, blue:0.714, alpha:1.000)
            case .Summary:
                return UIColor(red: 0.369, green: 0.408, blue: 0.686, alpha: 1.0)
            case .Ratio:
                return UIColor(red:0.180, green:0.361, blue:0.573, alpha:1.000)
            case .Availability:
                return UIColor(red: 0.7, green: 0.2, blue: 0.38, alpha: 1.0)
            }
        }

        func titleText() -> String {
            switch self {
            case .Daily:
                return "Daily Total"
            case .Summary:
                return "Summary"
            case .Ratio:
                return "Ratio"
            case .Availability:
                return "Availability"
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.restrationalServiceCodeIdentifier = "\(self.restorationIdentifier!).serviceCode"
        self.restrationalDurationSegmentIdentifier = "\(self.restorationIdentifier!).durationSegment"
        self.restrationalDataFilteringSegmentIdentifier = "\(self.restorationIdentifier!).dataFilteringSegment"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.restoreLastState()
        
        self.navBarHairlineImageView = self.findHairlineImageViewUnder(self.navigationController!.navigationBar)
        self.navBarHairlineImageView?.hidden = true
        self.navigationController?.navigationBar.translucent = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.chartDurationSegmentControl?.selectedSegmentIndex = self.chartDurationSegment.rawValue
    }

    // MARK: - Private

    private func findHairlineImageViewUnder(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            if let view = self.findHairlineImageViewUnder(subview as UIView) {
                return view
            }
        }
        return nil
    }

    // MARK: - StateRestorableProtocol

    func storeCurrentState() {
        NSUserDefaults().setObject(self.serviceCode ?? nil, forKey: self.restrationalServiceCodeIdentifier)
        NSUserDefaults().setInteger(self.chartDurationSegment.rawValue, forKey: self.restrationalDurationSegmentIdentifier)
        NSUserDefaults().setInteger(self.chartDataFilteringSegment.rawValue, forKey: self.restrationalDataFilteringSegmentIdentifier)
    }

    func restoreLastState() {
        if let serviceCode = NSUserDefaults().objectForKey(self.restrationalServiceCodeIdentifier) as? String {
            self.serviceCode = serviceCode
        }
        self.chartDurationSegment
            = HdoService.Duration(rawValue: NSUserDefaults().integerForKey(self.restrationalDurationSegmentIdentifier))!
        self.chartDataFilteringSegment
            = ChartDataFilteringSegment(rawValue: NSUserDefaults().integerForKey(self.restrationalDataFilteringSegmentIdentifier))!

        NSUserDefaults().setObject(nil, forKey: self.restrationalServiceCodeIdentifier)
        NSUserDefaults().setInteger(HdoService.Duration.InThisMonth.rawValue, forKey: self.restrationalDurationSegmentIdentifier)
        NSUserDefaults().setInteger(ChartDataFilteringSegment.All.rawValue, forKey: self.restrationalDataFilteringSegmentIdentifier)
    }

}
