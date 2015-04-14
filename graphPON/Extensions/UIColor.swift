import UIKit

extension UIColor {

    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString

        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }

        if (count(cString) != 6) {
            self.init(white: 0.0, alpha: alpha)
            return
        }

        var rString = (cString as NSString).substringToIndex(2)
        var gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        var bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)

        var red:CUnsignedInt = 0, green:CUnsignedInt = 0, blue:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&red)
        NSScanner(string: gString).scanHexInt(&green)
        NSScanner(string: bString).scanHexInt(&blue)

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }

}