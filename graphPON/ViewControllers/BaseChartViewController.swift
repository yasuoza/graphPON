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

class BaseChartViewController: BaseViewController, StateRestorable {

    @IBOutlet weak var extendedNavBarView: ExtendedNavBarView?
    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var chartInformationView: ChartInformationView!
    @IBOutlet weak var informationValueLabelSeparatorView: UIView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueLabelTopSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var chartDurationSegmentControl: UISegmentedControl?

    var serviceCode: String?
    var chartDataFilteringSegment: Coupon.Switch = .All
    var chartDurationSegment: HdoService.Duration = .InThisMonth

    private var navBarHairlineImageView: UIImageView?

    private(set) var restrationalServiceCodeIdentifier: String!
    private(set) var restrationalDurationSegmentIdentifier: String!
    private(set) var restrationalDataFilteringSegmentIdentifier: String!

    enum Mode {
        case Summary, Daily, Ratio, Availability

        func backgroundColor() -> UIColor {
            switch self {
            case .Summary:
                return UIColor(red: 0.369, green: 0.408, blue: 0.686, alpha: 1.0)
            case .Daily:
                return UIColor(red:0.376, green:0.573, blue:0.714, alpha:1.000)
            case .Ratio:
                return UIColor(red:0.180, green:0.361, blue:0.573, alpha:1.000)
            case .Availability:
                return UIColor(red: 0.7, green: 0.2, blue: 0.38, alpha: 1.0)
            }
        }

        func titleText() -> String {
            switch self {
            case .Summary:
                return NSLocalizedString("Summary", comment: "Summary")
            case .Daily:
                return NSLocalizedString("Daily", comment: "Daily")
            case .Ratio:
                return NSLocalizedString("Ratio", comment: "Ratio")
            case .Availability:
                return NSLocalizedString("Availability", comment: "Availability")
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.restrationalServiceCodeIdentifier = "\(self.restorationIdentifier!).serviceCode"
        self.restrationalDurationSegmentIdentifier = "\(self.restorationIdentifier!).durationSegment"
        self.restrationalDataFilteringSegmentIdentifier = "\(self.restorationIdentifier!).dataFilteringSegment"

        self.restoreLastState()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBarHairlineImageView = self.findHairlineImageViewUnder(self.navigationController!.navigationBar)
        self.navBarHairlineImageView?.hidden = true
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.chartDurationSegmentControl?.selectedSegmentIndex = self.chartDurationSegment.rawValue
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationDidBecomeActiveNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { _ in
                self.presentPromptLoginControllerIfNeeded()
        })

        switch OAuth2Client.sharedClient.state {
        case .UnAuthorized:
            self.presentPromptLoginControllerIfNeeded()
        default:
            break
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let extendedNavBarView = self.extendedNavBarView,
            let navBarFooterImageView = self.navBarHairlineImageView {
                navBarFooterImageView.hidden = false
                navBarFooterImageView.frame = CGRectMake(
                    extendedNavBarView.frame.origin.x,
                    extendedNavBarView.frame.origin.y + extendedNavBarView.frame.height,
                    navBarFooterImageView.frame.width,
                    navBarFooterImageView.frame.height
                )
        }

        if iOS3_5InchPortraitOrientation() {
            self.valueLabelTopSpaceConstraint.constant = -8.0
            self.valueLabel.font = UIFont(name: GlobalValueFontFamily, size: 60.0)
        }
    }

    // MARK: - Internal

    func iOS3_5InchPortraitOrientation() -> Bool {
        let compactWregularH = self.traitCollection.horizontalSizeClass == .Compact
            && self.traitCollection.verticalSizeClass == .Regular

        return compactWregularH && self.view.frame.height == 480.0
    }

    // MARK: - Private

    private func findHairlineImageViewUnder(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            if let view = self.findHairlineImageViewUnder(subview as! UIView) {
                return view
            }
        }
        return nil
    }

    // MARK: - StateRestorableProtocol

    func storeCurrentState() {
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        if let serviceCode = self.serviceCode {
            standardDefaults.setObject(serviceCode, forKey: self.restrationalServiceCodeIdentifier)
        }
        standardDefaults.setInteger(self.chartDurationSegment.rawValue, forKey: self.restrationalDurationSegmentIdentifier)
        standardDefaults.setInteger(self.chartDataFilteringSegment.rawValue, forKey: self.restrationalDataFilteringSegmentIdentifier)
    }

    func restoreLastState() {
        let standardDefaults = NSUserDefaults.standardUserDefaults()
        if let serviceCode = standardDefaults.objectForKey(self.restrationalServiceCodeIdentifier) as? String {
            self.serviceCode = serviceCode
        }
        self.chartDurationSegment
            = HdoService.Duration(rawValue: standardDefaults.integerForKey(self.restrationalDurationSegmentIdentifier))!
        self.chartDataFilteringSegment
            = Coupon.Switch(rawValue: standardDefaults.integerForKey(self.restrationalDataFilteringSegmentIdentifier))!

        standardDefaults.setObject(nil, forKey: self.restrationalServiceCodeIdentifier)
        standardDefaults.setInteger(HdoService.Duration.InThisMonth.rawValue, forKey: self.restrationalDurationSegmentIdentifier)
        standardDefaults.setInteger(Coupon.Switch.All.rawValue, forKey: self.restrationalDataFilteringSegmentIdentifier)
    }

}
