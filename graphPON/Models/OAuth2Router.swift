import UIKit
import Alamofire

enum OAuth2Router: URLRequestConvertible {
    private static let baseURLString = "https://api.iijmio.jp/mobile/d/v1"

    case Authorize
    case LogPacket

    var method: Alamofire.Method {
        switch self {
        case .Authorize:
            return .GET
        case .LogPacket:
            return .GET
        }
    }

    var path: String {
        switch self {
        case .Authorize:
            return "authorization"
        case .LogPacket:
            return "log/packet"
        }
    }

    var parameters: [String: AnyObject]? {
        switch self {
        case .Authorize:
            return [
                "response_type": "token",
                "client_id": OAuth2Client.sharedClient.iijDeveloperID,
                "state": "state",
                "redirect_uri": OAuth2Client.sharedClient.iijOAuthCallbackURI,
            ]
        default:
            return nil
        }
    }

    // MARK: URLStringConvertible

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: OAuth2Router.baseURLString)!
        let request = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        request.HTTPMethod = method.rawValue

        switch self {
        case .LogPacket:
            request.setValue(OAuth2Client.sharedClient.iijDeveloperID, forHTTPHeaderField: "X-IIJmio-Developer")
            request.setValue(OAuth2Client.sharedClient.accessToken, forHTTPHeaderField: "X-IIJmio-Authorization")
        default:
            () // noop
        }

        return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
    }

}
