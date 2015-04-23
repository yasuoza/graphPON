import Foundation
import Alamofire

public class OAuth2Client: NSObject {

    public enum AuthorizationState {
        case UnAuthorized
        case Authorized(OAuth2Credential)
    }

    // MARK: - Singleton variables

    public static let OAuthDidAuthorizeNotification = "com.yasuoza.mobilegraphpon.OAuthDidAuthorizeNotification"
    public static let sharedClient = OAuth2Client()

    // MARK: - Instance variables

    let iijDeveloperID: String!
    let iijOAuthCallbackURI: NSURL!

    private(set) var credential: OAuth2Credential?
    public private(set) var state: AuthorizationState = .UnAuthorized {
        didSet {
            switch self.state {
            case .Authorized(let credential):
                self.credential = credential
                NSNotificationCenter.defaultCenter().postNotificationName(
                    OAuth2Client.OAuthDidAuthorizeNotification,
                    object: nil
                )
            default:
                self.credential = nil
            }
        }
    }

    // MARK: - Singleton methods

    public class func parseQuery(query: String?) -> [String: String]? {
        return query?.componentsSeparatedByString("&")
            .map { keyValue in
                keyValue.componentsSeparatedByString("=")
            }.reduce([:] as [String: String]) { (var dict, elem) in
                if let key = elem.first, let value = elem.last {
                    dict[key] = String(value).stringByRemovingPercentEncoding
                }
                return dict
        }
    }

    // MARK: - Instance methods

    override init() {
        let callbackURLString = NSBundle(forClass: self.dynamicType)
            .objectForInfoDictionaryKey("IIJAPICallbackURL") as! String
        self.iijDeveloperID = NSBundle(forClass: self.dynamicType)
            .objectForInfoDictionaryKey("IIJAPIClientKey") as! String
        self.iijOAuthCallbackURI = NSURL(string: callbackURLString)

        if let credential = OAuth2Credential.restoreCredential() {
            self.state = .Authorized(credential)

            // willSet and didSet observers are not called when a property
            // is set in an initializer before delegation takes place.
            // https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-ID262
            self.credential = credential
        }
    }

    public func authorized(credential cred: OAuth2Credential) {
        self.state = .Authorized(cred)
    }

    public func deauthorize() {
        self.state = .UnAuthorized
    }

}
