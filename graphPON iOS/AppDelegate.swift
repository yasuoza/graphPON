import UIKit
import GraphPONDataKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window?.tintColor = GlobalTintColor

        GPUserDefaults.migrateFromOldDefaultsIfNeeded()

        let selectedIndex = GPUserDefaults.sharedDefaults().integerForKey("selectedIndex")
        if let tabBarController = window?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = selectedIndex
        }

        self.fetchLatestPacketLog()

        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if OAuth2Router.validOAuthCallbackURL(url),
            let params = OAuth2Client.parseQuery(url.fragment) {
                let credential = GraphPONDataKit.OAuth2Credential(dictionary: params)
                if credential.save() {
                    if let tabBarController = self.window?.rootViewController as? UITabBarController,
                        let navVC = tabBarController.selectedViewController as? UINavigationController,
                        let loginController = navVC.visibleViewController as? PromptLoginController {
                            loginController.dismissViewControllerAnimated(true, completion: nil)

                    }
                    OAuth2Client.sharedClient.authorized(credential: credential)
                    self.fetchLatestPacketLog()
                    return true
                }
        }

        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

        if let tabBarController = window?.rootViewController as? UITabBarController {
            let selectedIndex = tabBarController.selectedIndex
            GPUserDefaults.sharedDefaults().setInteger(selectedIndex, forKey: "selectedIndex")
            for vc in tabBarController.viewControllers! {
                if let navVC = vc as? UINavigationController,
                    let vc = navVC.viewControllers.first as? StateRestorable {
                        vc.storeCurrentState()
                }
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        self.fetchLatestPacketLog()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the backgro
    }

    func applicationWillTerminate(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the backgrond, optionally refresh the user interface.
    }

    // MARK: - Private methods

    private func fetchLatestPacketLog() {
        switch OAuth2Client.sharedClient.state {
        case .Authorized:
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            PacketInfoManager.sharedManager.fetchLatestPacketLog(completion: { error in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.handleAPIError(error)
            })
        default:
            break
        }
    }

    private func handleAPIError(error: NSError?) {
        if let error = error,
            let tabBarController = self.window?.rootViewController as? UITabBarController,
            let navVC = tabBarController.selectedViewController as? UINavigationController {
                if error.domain == OAuth2Router.APIErrorDomain && error.code == OAuth2Router.AuthorizationFailureErrorCode,
                    let vc = navVC.visibleViewController as? PromptLoginPresenter {
                        return vc.presentPromptLoginControllerIfNeeded()
                } else if let vc = navVC.visibleViewController as? ErrorAlertPresenter {
                    return vc.presentErrorAlertController(error)
                }
        }
    }

}
