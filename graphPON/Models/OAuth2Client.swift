import UIKit
import Alamofire

class OAuth2Client: NSObject {

    let iijDeveloperID: String!
    let iijOAuthCallbackURI: NSURL!

    var accessToken: String?

    // MARK: - Singleton methods

    class func parseQuery(query: String?) -> Dictionary<String, String>? {
        return query?.componentsSeparatedByString("&")
            .map { keyValue in
                keyValue.componentsSeparatedByString("=")
            }.reduce([:] as Dictionary<String, String>) { (var dict, elem) in
                if elem.first? == nil || elem.last? == nil {
                    return dict
                }
                dict[elem.first!] = String(elem.last!)
                return dict
        }
    }

    // MARK: - Instance methods

    override init() {
        super.init()

        let configurationPlistPath = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")!
        let configuration = NSDictionary(contentsOfFile: configurationPlistPath)!
        let iijConfiguration = (configuration["IIJ_API"] as Dictionary<String, String>)
        self.iijDeveloperID = iijConfiguration["CLIENT_KEY"]
        self.iijOAuthCallbackURI = NSURL(string: iijConfiguration["OAUTH_CALLBACK_URI"]!)
    }

    class var sharedClient: OAuth2Client {
        struct Singleton {
            static let instance = OAuth2Client()
        }

        return Singleton.instance
    }

    func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
        return Alamofire.request(URLRequest)
    }

    func authorize() {
        UIApplication.sharedApplication().openURL(OAuth2Router.Authorize.URLRequest.URL)
    }

}
