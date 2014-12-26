import UIKit
import Alamofire

class OAuth2Client: NSObject {

    let iijDeveloperID: String!
    let iijOAuthCallbackURI: String!

    var accessToken: String?

    override init() {
        super.init()

        let configurationPlistPath = NSBundle.mainBundle().pathForResource("configuration", ofType: "plist")!
        let configuration = NSDictionary(contentsOfFile: configurationPlistPath)!
        let iijConfiguration = (configuration["IIJ_API"] as Dictionary<String, String>)
        self.iijDeveloperID = iijConfiguration["CLIENT_KEY"]
        self.iijOAuthCallbackURI = iijConfiguration["OAUTH_CALLBACK_URI"]
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
