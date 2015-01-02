import UIKit

class BaseChartViewController: UIViewController, UIAlertViewDelegate {

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

    // MARK: - UIAlertViewDelegate

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch buttonIndex {
        case 0:
            OAuth2Client.sharedClient.openOAuthAuthorizeURL()
        default:
            // Close alertView
            break
        }
    }

}
