import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        window.rootViewController = UINavigationController(rootViewController: MenuViewController())
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

