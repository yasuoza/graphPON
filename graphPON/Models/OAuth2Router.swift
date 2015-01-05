import UIKit
import Alamofire

enum OAuth2Router: URLRequestConvertible {
    static let APIErrorDomain = "com.yasuoza.graphPON.apierror"
    static let AuthorizationFailureErrorCode: Int = 403
    static let TooManyRequestErrorCode: Int = 403
    static let UnknownErrorCode: Int = 403

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

    // MARK: - URLStringConvertible

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: OAuth2Router.baseURLString)!
        let request = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        request.HTTPMethod = method.rawValue

        switch self {
        case .LogPacket:
            request.setValue(OAuth2Client.sharedClient.iijDeveloperID, forHTTPHeaderField: "X-IIJmio-Developer")
            if let accessToken = OAuth2Client.sharedClient.credential?.accessToken {
                request.setValue(accessToken, forHTTPHeaderField: "X-IIJmio-Authorization")
            }
        default:
            break
        }

        return Alamofire.ParameterEncoding.URL.encode(request, parameters: parameters).0
    }

    // MARK: - Singleton methods

    static func validOAuthCallbackURL(url: NSURL) -> Bool {
        return url.host? == OAuth2Client.sharedClient.iijOAuthCallbackURI.host?
    }

}
