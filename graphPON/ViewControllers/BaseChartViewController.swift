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

class BaseChartViewController: UIViewController {

    @IBOutlet weak var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var chartInformationView: ChartInformationView!
    @IBOutlet weak var informationValueLabelSeparatorView: UIView!
    @IBOutlet weak var valueLabel: UILabel!

    private var navBarHairlineImageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBarHairlineImageView = self.findHairlineImageViewUnder(self.navigationController!.navigationBar)
        self.navBarHairlineImageView?.hidden = true
        self.navigationController?.navigationBar.translucent = true
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
    
}
