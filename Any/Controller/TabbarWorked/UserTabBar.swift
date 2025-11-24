//


import UIKit
import SwiftyJSON
import SDWebImage

class UserTabBar: UITabBarController {
    
    var indexSelect = 0
    var firstName = ""
    var dic_Profile:JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = indexSelect
        UITabBar.appearance().unselectedItemTintColor = .white
        UITabBar.appearance().barTintColor = UIColor(named: THEME_COLOR_NAME)
        if Utility.isUserLogin() {
            GetProfile()
        }
    }
    
    private func updateTabBarTitles() {
        // Assuming tab at index 1 is the one you want to update
        if let viewControllers = self.viewControllers {
            let vC3 = viewControllers[4]
            
            // Check the current language and update the title accordingl
            
            vC3.tabBarItem.title = firstName
            
            Utility.downloadImageBySDWebImage(self.dic_Profile?["image"].stringValue ?? "") { image, error in
                let circularImage: UIImage
                
                if let image = image, error == nil {
                    circularImage = self.makeCircularImage(image, size: CGSize(width: 30, height: 30))?
                        .withRenderingMode(.alwaysOriginal) ?? UIImage()
                } else {
                    circularImage = self.makeCircularImage(R.image.profile_Pla(), size: CGSize(width: 30, height: 30))?
                        .withRenderingMode(.alwaysOriginal) ?? UIImage()
                }
                
                // Assign the properly rendered image to the tab bar item
                vC3.tabBarItem.image = circularImage
            }
        }
    }
    
    func GetProfile() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_profile.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.dic_Profile = swiftyJsonVar["result"]
                    kappDelegate.dic_Profile = swiftyJsonVar["result"]
                    self.firstName = "\(self.dic_Profile?["first_name"].stringValue ?? "" )"
                    self.updateTabBarTitles()
                    //                    self.imgProfile.sd_setImage(with: URL.init(string: (self.dic_Profile?["image"].stringValue)!), placeholderImage: UIImage.init(named: "placeholder1"), options: SDWebImageOptions(rawValue: 1), completed: nil)
                } else {
                    let message = swiftyJsonVar["result"].string
                }
                self.hideProgressBar()
            }
            
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    private func makeCircularImage(_ image: UIImage?, size: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let rect = CGRect(origin: .zero, size: size)
            
            // Create circular path
            UIBezierPath(ovalIn: rect).addClip()
            
            // Draw the image within the circular path
            image.draw(in: rect)
        }
    }
}
