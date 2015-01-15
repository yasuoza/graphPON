import Foundation

@objc protocol StateRestorable {
    func storeCurrentState()
    func restoreLastState()
}
