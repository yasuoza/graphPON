import UIKit

class BaseChartViewController: UIViewController {

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
