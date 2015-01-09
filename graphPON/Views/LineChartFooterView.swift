import UIKit

class LineChartFooterView: UIView {

    var footerSeparatorColor: UIColor! = UIColor.whiteColor()
    var sectionCount: NSInteger! = 2
    var leftLabel: UILabel! = UILabel()
    var rightLabel: UILabel! = UILabel()

    private var topSeparatorView: UIView! = UIView()

    // MARK: - Alloc/Init

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()

        self.topSeparatorView.backgroundColor = self.footerSeparatorColor
        self.addSubview(self.topSeparatorView)

        self.leftLabel.adjustsFontSizeToFitWidth = true
        self.leftLabel.textAlignment = NSTextAlignment.Left
        self.leftLabel.textColor = UIColor.whiteColor()
        self.leftLabel.backgroundColor = UIColor.clearColor()
        self.addSubview(self.leftLabel)

        self.rightLabel.adjustsFontSizeToFitWidth = true
        self.rightLabel.textAlignment = NSTextAlignment.Right
        self.rightLabel.textColor = UIColor.whiteColor()
        self.rightLabel.backgroundColor = UIColor.clearColor()
        self.addSubview(self.rightLabel)
    }

    // MARK: - Drawing

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, self.footerSeparatorColor.CGColor)
        CGContextSetLineWidth(context, 0.5)
        CGContextSetShouldAntialias(context, true)

        var xOffset = CGFloat(0)
        let yOffset = CGFloat(0.5)
        let stepLength = ceil(CGFloat(self.bounds.size.width) / CGFloat(self.sectionCount - 1))

        for (var i = 0; i < self.sectionCount; i++) {
            CGContextSaveGState(context)
            CGContextMoveToPoint(context, xOffset + (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset)
            CGContextAddLineToPoint(context,
                xOffset + (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset + kJBLineChartFooterViewSeparatorHeight)
            CGContextStrokePath(context)
            xOffset += stepLength;
            CGContextRestoreGState(context);
        }

        if (self.sectionCount > 1) {
            CGContextSaveGState(context)
            CGContextMoveToPoint(context, self.bounds.size.width - (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset)
            CGContextAddLineToPoint(context,
                self.bounds.size.width - (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset + kJBLineChartFooterViewSeparatorHeight)
            CGContextStrokePath(context)
            CGContextRestoreGState(context);
        }
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        self.topSeparatorView.frame = CGRectMake(
            self.bounds.origin.x,
            self.bounds.origin.y,
            self.bounds.size.width,
            kJBLineChartFooterViewSeparatorWidth
        )

        let xOffset = CGFloat(0)
        let yOffset = kJBLineChartFooterViewSeparatorSectionPadding
        let width = ceil(self.bounds.size.width * 0.5)

        self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height)
        self.rightLabel.frame = CGRectMake(CGRectGetMaxX(self.leftLabel.frame), yOffset, width, self.bounds.size.height)
    }
    
}
