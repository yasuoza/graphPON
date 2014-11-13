import UIKit

class ChartTooltipView: UIView {

    let textLabel = UILabel()

    private let kJBChartTooltipViewCornerRadius  = CGFloat(5.0)
    private let kJBChartTooltipViewDefaultWidth  = CGFloat(50.0)
    private let kJBChartTooltipViewDefaultHeight = CGFloat(25.0)

    // MARK: - ALloc/Init

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init(frame: CGRectMake(
            0,
            0,
            kJBChartTooltipViewDefaultWidth,
            kJBChartTooltipViewDefaultHeight
            )
        )
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = kJBChartTooltipViewCornerRadius
        self.textLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        self.textLabel.backgroundColor = UIColor.clearColor()
        self.textLabel.textColor = UIColor(hex: "313131")
        self.textLabel.adjustsFontSizeToFitWidth = true
        self.textLabel.numberOfLines = 1
        self.textLabel.textAlignment = NSTextAlignment.Center
        self.addSubview(self.textLabel)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        self.textLabel.frame = self.bounds
    }

    // MARK: - Setters

    func setText(text: String) {
        self.textLabel.text = text
        self.setNeedsDisplay()
    }

    func setTooltipColor(color: UIColor) {
        self.backgroundColor = color
        self.setNeedsDisplay()
    }

}
