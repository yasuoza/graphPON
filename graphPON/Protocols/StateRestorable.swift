import Foundation

@objc protocol StateRestorable {
    var restrationalServiceCodeIdentifier: String! { get }
    var restrationalDurationSegmentIdentifier: String! { get }
    var restrationalDataFilteringSegmentIdentifier: String! { get }

    func storeCurrentState()
    func restoreLastState()
}
