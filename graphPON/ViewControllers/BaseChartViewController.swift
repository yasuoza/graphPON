import UIKit

class BaseChartViewController: UIViewController {

    override func loadView() {
        super.loadView()

        if self.respondsToSelector(Selector("setEdgesForExtendedLayout:")) {
            self.edgesForExtendedLayout = UIRectEdge.Top
        }
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationItem.title = "this is super title"
    }

}
