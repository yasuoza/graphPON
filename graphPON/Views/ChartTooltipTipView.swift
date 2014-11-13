import UIKit

class ChartTooltipTipView: UIView {

    // MARK: - Alloc/Init

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init() {
        super.init(frame: CGRectMake(0, 0, 8.0, 5.0))
        self.backgroundColor = UIColor.clearColor()
    }

    // MARK: - Drawing

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let context = UIGraphicsGetCurrentContext()
        UIColor.clearColor().set()
        CGContextFillRect(context, rect)

        CGContextSaveGState(context)
        CGContextBeginPath(context)
        CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect))
        CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMinY(rect))
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect))
        CGContextClosePath(context)
        CGContextSetFillColorWithColor(context, UIColor(white: 1.0, alpha: 0.9).CGColor)
        CGContextFillPath(context)

        CGContextRestoreGState(context)
    }
}
