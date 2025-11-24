

import Foundation
import UIKit
//import SlideMenuControllerSwift

class Switcher {
    
    static func updateRootVC() {
        
        if USER_DEFAULT.value(forKey: STATUS) != nil {
            
            if USER_DEFAULT.value(forKey: USER_TYPE) as! String == "Client" {
                let vc = Mainboard.instantiateViewController(withIdentifier: "TabBarClientVC") as! TabBarClientVC
                let navigation = UINavigationController.init(rootViewController: vc)
                navigation.isNavigationBarHidden = true
                APP_DELEGATE.window?.rootViewController = navigation
                APP_DELEGATE.window?.makeKeyAndVisible()
            } else {
                let vc = Mainboard.instantiateViewController(withIdentifier: "UserTabBar") as! UserTabBar
                let navigation = UINavigationController.init(rootViewController: vc)
                navigation.isNavigationBarHidden = true
                APP_DELEGATE.window?.rootViewController = navigation
                APP_DELEGATE.window?.makeKeyAndVisible()
            }
        } else {
            let rightViewController1 = Mainboard.instantiateViewController(withIdentifier: "LoginTypeVC") as! LoginTypeVC
            let navigation = UINavigationController.init(rootViewController: rightViewController1)
            APP_DELEGATE.window?.rootViewController = navigation
            APP_DELEGATE.window?.makeKeyAndVisible()
        }
    }
}
