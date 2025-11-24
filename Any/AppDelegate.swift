
import UIKit
//import IQKeyboardManagerSwift
import CoreLocation
import SwiftyJSON
import UserNotifications
import Firebase
import FirebaseMessaging
import StripeCore
import IQKeyboardManagerSwift

@UIApplicationMain //
class AppDelegate: UIResponder,  UIApplicationDelegate, MessagingDelegate {
    
    var window: UIWindow?
    var CURRENT_LAT = "0.0"
    var CURRENT_LON = "0.0"
    var isValidLocation:Bool = true
    var coordinate1 = CLLocation(latitude: 0.0, longitude: 0.0)
    var coordinate2 = CLLocation(latitude: 0.0, longitude: 0.0)
    var arr_allWorkout:[JSON]? = []
    var strCatID:String! = ""
    var strTitle:String! = ""
    var strUrl:String! = ""
    var strHeading:String! = ""
    var strEventTitle:String! = "WHEN"
    var arr_Ticket:[JSON] = []
    var strBack:String! = "back"
    var strPlanId:String! = ""
    
    var dicProdile:JSON!
    var dic_Profile:JSON!
    var dicCrent:JSON!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        LocationManager.sharedInstance.delegate = APP_DELEGATE
        LocationManager.sharedInstance.startUpdatingLocation()
        USER_DEFAULT.set("IOS_TOKEN123", forKey: IOS_TOKEN)
        
        StripeAPI.defaultPublishableKey = "pk_live_51J2qDbFQ7R30RqjsyCXuC4QRtLYrPoH8B2ycKMhlBCO47mvR1jTA97usIWHdzYMcQ3iAkRVdIX6qQtziE5fofONI00SpVUmiJi"
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true

        UIApplication.shared.applicationIconBadgeNumber = 0
        UNUserNotificationCenter.current().delegate = self
        
        self.configureNotification()
        VersionManager.shared.checkAppVersion()
        
        if USER_DEFAULT.value(forKey: STATUS) != nil {
            Switcher.updateRootVC()
        }
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundEffect = .none
            tabBarAppearance.shadowColor = .clear
            tabBarAppearance.backgroundColor = UIColor.white
            UITabBar.appearance().standardAppearance = tabBarAppearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func configureNotification() {
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
        }
        
        UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                USER_DEFAULT.set(token, forKey: IOS_TOKEN)
                //k.iosRegisterId = token
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        // k.iosRegisterId = deviceTokenString
        Messaging.messaging().apnsToken = deviceToken
        print("APNs device token: \(deviceTokenString)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    
    // MARK:-  Received Remote Notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print(userInfo)
        if let info = userInfo["aps"] as? Dictionary<String, AnyObject> {
            print(info)
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
}

extension AppDelegate:LocationManagerDelegate {
    
    func tracingLocation(currentLocation: CLLocation) {
        coordinate2 = currentLocation
        _ = coordinate1.distance(from: coordinate2) // result is in meters
        //  if distanceInMeters > 0 {
        CURRENT_LAT = String(currentLocation.coordinate.latitude)
        CURRENT_LON = String(currentLocation.coordinate.longitude)
        coordinate1 = currentLocation
        //  }
        
    }
    
    func tracingLocationDidFailWithError(error: NSError) {
        
    }
}

//MARK:Extention

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Notification received: \(userInfo)")
        
        // Check if sound key is present
        if let aps = userInfo["aps"] as? [String: AnyObject], let sound = aps["sound"] as? String {
            print("Sound key is present: \(sound)")
        } else {
            print("Sound key is missing.")
        }
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        if let info = userInfo as? Dictionary<String, AnyObject> {
//            let alert1 = info["aps"]!["alert"] as! Dictionary<String, AnyObject>
            let title = userInfo["title"]  ?? ""
            hanleNotification(info: info, strStatus: title as! String, strFrom: "Back")
        }
        completionHandler()
    }
    
    func hanleNotification(info: Dictionary<String, AnyObject>, strStatus: String, strFrom: String) {
        // Directly use the info dictionary since it already contains the necessary data
        print(info)
        if let apsInfoMessage = info["message"] as? String {
//            let notiTitle = apsInfoMessage["noti_title"] as? String ?? "No Title"
            print(apsInfoMessage)
            let notiAlert = info["noti_alert"] as? String ?? "No Alert"
            let notiKey = info["message"]?["noti_key"] as? String ?? "No Key"
            print(notiKey)
            let senderId = info["noti_sender_id"] as? String ?? ""
            let senderName = info["noti_sender_name"] as? String ?? ""
            let senderImage = info["noti_sender_image"] as? String ?? ""
            let requestId = info["noti_request_id"] as? String ?? ""
            
            let visibleVC = UIApplication.shared.topmostViewController()
            
            if notiKey == "You have a new message" && strFrom == "Back" {
                if visibleVC is UserChat {
                    NotificationCenter.default.post(name: NSNotification.Name("NewMessage"), object: "On Ride", userInfo: nil)
                } else {
                    let objVC = Mainboard.instantiateViewController(withIdentifier: "UserChat") as! UserChat
                    objVC.receiverId = senderId
                    objVC.userName = senderName
                    objVC.strReasonID = requestId
                    visibleVC?.navigationController?.pushViewController(objVC, animated: true)
                }
            } else if notiKey == "You have a new message" && strFrom == "Front" {
                if visibleVC is UserChat {
                    NotificationCenter.default.post(name: NSNotification.Name("NewMessage"), object: "On Ride", userInfo: nil)
                }
            } else {
                if strFrom == "Back" {
                    Switcher.updateRootVC()
                }
                NotificationCenter.default.post(name: NSNotification.Name("ReloadCount"), object: "On Ride", userInfo: nil)
            }

        }

        
    }
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter,
    //                                didReceive response: UNNotificationResponse,
    //                                withCompletionHandler completionHandler: @escaping () -> Void) {
    //        let userInfo = response.notification.request.content.userInfo
    //
    //        print("Notification received: \(userInfo)")
    //
    //        if let messageInfo = userInfo["message"] as? [String: AnyObject] {
    //            let notiTitle = messageInfo["noti_title"] as? String ?? ""
    //            let notiAlert = messageInfo["noti_alert"] as? String ?? ""
    //            let notiKey = messageInfo["noti_key"] as? String ?? ""
    //            let notiMessage = messageInfo["noti_message"] as? String ?? ""
    //            let notiSenderName = messageInfo["noti_sender_name"] as? String ?? ""
    //            let notiSenderImage = messageInfo["noti_sender_image"] as? String ?? ""
    //            let notiType = messageInfo["noti_type"] as? String ?? ""
    //            let notiRequestId = messageInfo["noti_request_id"] as? String ?? ""
    //
    //            print("Notification Details: Title: \(notiTitle), Alert: \(notiAlert), Key: \(notiKey), Message: \(notiMessage), Sender Name: \(notiSenderName), Sender Image: \(notiSenderImage), Type: \(notiType), Request ID: \(notiRequestId)")
    //
    //            // Call your custom handling method here
    //            hanleNotification(info: messageInfo, strStatus: notiKey, strFrom: "Back")
    //        } else {
    //            print("Message key is missing in notification payload.")
    //        }
    //
    //        completionHandler()
    //    }
    //
    //    func hanleNotification(info:Dictionary<String,AnyObject>,strStatus:String,strFrom:String) {
    //
    //        guard let messageInfo = info["message"] as? [String: AnyObject] else {
    //            print("Message data not found")
    //            return
    //        }
    //
    //        let notiTitle = messageInfo["noti_title"] as? String ?? "No Title"
    //        let notiAlert = messageInfo["noti_alert"] as? String ?? "No Alert"
    //        let notiKey = messageInfo["noti_key"] as? String ?? "No Key"
    //        let senderId = messageInfo["noti_sender_id"] as? String ?? ""
    //        let senderName = messageInfo["noti_sender_name"] as? String ?? ""
    //        let senderImage = messageInfo["noti_sender_image"] as? String ?? ""
    //        let requestId = messageInfo["noti_request_id"] as? String ?? ""
    //
    //        let visibleVC = UIApplication.shared.topmostViewController()
    //
    //        if notiKey == "You have a new message" && strFrom == "Back" {
    //            if visibleVC is UserChat {
    //                NotificationCenter.default.post(name: NSNotification.Name("NewMessage"), object: "On Ride", userInfo: nil)
    //            } else {
    //                let objVC = Mainboard.instantiateViewController(withIdentifier: "UserChat") as! UserChat
    //                objVC.receiverId = senderId
    //                objVC.userName = senderName
    //                objVC.strReasonID = requestId
    //                visibleVC?.navigationController?.pushViewController(objVC, animated: true)
    //            }
    //        } else if notiKey == "You have a new message" && strFrom == "Front" {
    //            if visibleVC is UserChat {
    //                NotificationCenter.default.post(name: NSNotification.Name("NewMessage"), object: "On Ride", userInfo: nil)
    //            }
    //        } else {
    //            if strFrom == "Back" {
    //                Switcher.updateRootVC()
    //            }
    //            NotificationCenter.default.post(name: NSNotification.Name("ReloadCount"), object: "On Ride", userInfo: nil)
    //        }
    //    }
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter,
    //                                didReceive response: UNNotificationResponse,
    //                                withCompletionHandler completionHandler: @escaping () -> Void) {
    //        let userInfo = response.notification.request.content.userInfo
    //        print(userInfo)
    //        if let info = userInfo as? Dictionary<String, AnyObject> {
    //            let alert1 = info["aps"]!["alert"] as! Dictionary<String, AnyObject>
    //            let title = userInfo["gcm.notification.ios_status"]  ?? ""
    //            hanleNotification(info: info, strStatus: title as! String, strFrom: "Back")
    //        }
    //        completionHandler()
    //    }
    //
    //    //MARK:GoViewCotroller
    //
    //    func hanleNotification(info:Dictionary<String,AnyObject>,strStatus:String,strFrom:String) {
    //
    //        let visibleVC = UIApplication.shared.topmostViewController()
    //
    //        if strStatus == "You have a new message" && strFrom == "Back" {
    //
    //            if visibleVC is UserChat {
    //                NotificationCenter.default.post(name: NSNotification.Name("NewMessage"), object: "On Ride", userInfo: nil)
    //            } else {
    //                let objVC = Mainboard.instantiateViewController(withIdentifier: "UserChat") as! UserChat
    //                objVC.receiverId = (info["gcm.notification.sender_id"] as? String)!
    //                objVC.userName = (info["gcm.notification.user_name"] as? String)!
    //                objVC.strReasonID = (info["gcm.notification.request_id"] as? String)!
    //                visibleVC?.navigationController?.pushViewController(objVC, animated: true)
    //            }
    //        } else if strStatus == "You have a new message" && strFrom == "Front" {
    //            if visibleVC is UserChat {
    //                NotificationCenter.default.post(name: NSNotification.Name("NewMessage"), object: "On Ride", userInfo: nil)
    //            }
    //        } else {
    //            if strFrom == "Back" {
    //                Switcher.updateRootVC()
    //            }
    //            NotificationCenter.default.post(name: NSNotification.Name("ReloadCount"), object: "On Ride", userInfo: nil)
    //        }
    //    }
    
    
    func goChatVC() {
        let visibleVC = UIApplication.topViewController()!
        visibleVC.tabBarController?.selectedIndex = 1
        Utility.showAlertMessage(withTitle: APPNAME, message: "", delegate: nil, parentViewController: visibleVC)
    }
    
    func OpenNewme(dict:NSDictionary,application:UIApplication) {
        let visibleVC = UIApplication.topViewController()
        let vc = Mainboard.instantiateViewController(withIdentifier: "UserChat") as! UserChat
        visibleVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
extension UIViewController {
    func topmostViewController() -> UIViewController {
        
        if let navigationVC = self as? UINavigationController,
           let topVC = navigationVC.topViewController {
            return topVC.topmostViewController()
        }
        
        if let tabBarVC = self as? UITabBarController,
           let selectedVC = tabBarVC.selectedViewController {
            return selectedVC.topmostViewController()
        }
        
        if let presentedVC = presentedViewController {
            return presentedVC.topmostViewController()
        }
        
        if let childVC = children.first {
            return childVC.topmostViewController()
        }
        
        return self
    }
}

extension UIApplication {
    func topmostViewController() -> UIViewController? {
        return keyWindow?.rootViewController?.topmostViewController()
    }
}
