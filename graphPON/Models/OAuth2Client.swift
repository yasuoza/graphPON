import UIKit
import Alamofire

class OAuth2Client: NSObject {

    enum AuthorizationState {
        case UnAuthorized
        case Authorized(OAuth2Credential)
    }

    class var OAuthDidAuthorizeNotification: String {
        struct Notification {
            static let name = "graphPON.OAuthDidAuthorizeNotification"
        }
        return Notification.name
    }

    let iijDeveloperID: String!
    let iijOAuthCallbackURI: NSURL!

    private(set) var credential: OAuth2Credential?
    private(set) var state: AuthorizationState = AuthorizationState.UnAuthorized {
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

    class func parseQuery(query: String?) -> [String: String]? {
        return query?.componentsSeparatedByString("&")
            .map { keyValue in
                keyValue.componentsSeparatedByString("=")
            }.reduce([:] as [String: String]) { (var dict, elem) in
                if elem.first? == nil || elem.last? == nil {
                    return dict
                }
                dict[elem.first!] = String(elem.last!).stringByRemovingPercentEncoding
                return dict
        }
    }

    class var sharedClient: OAuth2Client {
        struct Singleton {
            static let instance = OAuth2Client()
        }

        return Singleton.instance
    }

    // MARK: - Instance methods

    override init() {
        super.init()

        let configurationPlistPath = NSBundle(forClass: OAuth2Client.self)
                                        .pathForResource("configuration", ofType: "plist")!
        let configuration = NSDictionary(contentsOfFile: configurationPlistPath)!
        let iijConfiguration = configuration["IIJ_API"] as [String: String]
        self.iijDeveloperID = iijConfiguration["CLIENT_KEY"]
        self.iijOAuthCallbackURI = NSURL(string: iijConfiguration["OAUTH_CALLBACK_URI"]!)

        if let credential = OAuth2Credential.restoreCredential()? {
            self.state = .Authorized(credential)

            // willSet and didSet observers are not called when a property
            // is set in an initializer before delegation takes place.
            // https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Properties.html#//apple_ref/doc/uid/TP40014097-CH14-XID_390
            self.credential = credential

            NSNotificationCenter.defaultCenter().postNotificationName(
                OAuth2Client.OAuthDidAuthorizeNotification,
                object: nil
            )
        }
    }

    func openOAuthAuthorizeURL() {
        UIApplication.sharedApplication().openURL(OAuth2Router.Authorize.URLRequest.URL)
    }

    func authorized(credential cred: OAuth2Credential) {
        self.state = .Authorized(cred)
    }

    func deauthorize() {
        self.state = .UnAuthorized
    }

}
