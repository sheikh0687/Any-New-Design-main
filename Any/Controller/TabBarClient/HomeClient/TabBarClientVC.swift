//
//  TabBarClientVC.swift
//  Any
//
//  Created by mac on 28/05/23.
//

import UIKit
import SwiftyJSON

class TabBarClientVC: UITabBarController {

    var indexSelect = 0
    var dic_Profile:JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//         GetProfile()
    }
    
    private func updateTabBarTitles() {
        // Assuming tab at index 1 is the one you want to update
        if let viewControllers = self.viewControllers {
            let vC2 = viewControllers[2]
            
            // Check the current language and update the title accordingl
            
            vC2.tabBarItem.title = "Profile"
            
            Utility.downloadImageBySDWebImage(self.dic_Profile?["image"].stringValue ?? "") { image, error in
                let circularImage: UIImage
                
                if let image = image, error == nil {
                    circularImage = self.makeCircularImage(image, size: CGSize(width: 30, height: 30))?
                        .withRenderingMode(.alwaysOriginal) ?? UIImage()
                } else {
                    circularImage = self.makeCircularImage(R.image.jonathan(), size: CGSize(width: 30, height: 30))?
                        .withRenderingMode(.alwaysOriginal) ?? UIImage()
                }
                
                // Assign the properly rendered image to the tab bar item
                vC2.tabBarItem.image = circularImage
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
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.dic_Profile = swiftyJsonVar["result"]
                    self.updateTabBarTitles()
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
