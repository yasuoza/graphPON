import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        window?.tintColor = GlobalTintColor

        let selectedIndex = NSUserDefaults().integerForKey("selectedIndex")
        if let tabBarController = window?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = selectedIndex
        }

        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if OAuth2Router.validOAuthCallbackURL(url) {
            let parsedQuery = OAuth2Client.parseQuery(url.fragment)
            if let dict = parsedQuery {
                let credential = OAuth2Credential(dictionary: dict)
                if credential.save() {
                    OAuth2Client.sharedClient.authorized(credential: credential)
                    PacketInfoManager.sharedManager.fetchLatestPacketLog(completion: nil)
                    return true
                }
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

        if let tabBarController = window?.rootViewController as UITabBarController? {
            let selectedIndex = tabBarController.selectedIndex
            NSUserDefaults().setInteger(selectedIndex, forKey: "selectedIndex")
            for vc in tabBarController.viewControllers! {
                if let navVC = vc as? UINavigationController {
                    if let vc = navVC.viewControllers.first as? StateRestorable {
                        vc.storeCurrentState()
                    }
                }
            }
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        switch OAuth2Client.sharedClient.state {
        case .Authorized:
            PacketInfoManager.sharedManager.fetchLatestPacketLog(completion: nil)
        default:
            break
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // REQUIRED FOR STATE RESTORATION
    // Identify we are interested in storing application state, this is called when the app is suspended to the background.
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    // REQUIRED FOR STATE RESTORATION
    // Identify we are interested in re-storing application state, this is called when the app is re-launched.
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
}
