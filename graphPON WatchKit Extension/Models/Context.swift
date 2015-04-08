import Foundation

class Context: NSObject {

    class var sharedContext: Context {
        struct Instance {
            private static let instance = Context()
        }
        return Instance.instance
    }

    var serviceCode: String?
    var serviceNickname: String?

}
