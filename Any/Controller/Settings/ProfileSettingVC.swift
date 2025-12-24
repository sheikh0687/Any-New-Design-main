//
//  ProfileSettingVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 09/10/24.
//

import UIKit
import SwiftyJSON
import SwiftUI

class ProfileSettingVC: UIViewController{

    @IBOutlet weak var businessProfile_Vw: UIStackView!
    @IBOutlet weak var userProfile_Vw: UIStackView!
    @IBOutlet weak var btn_DeleteAccountOt: UIButton!
    @IBOutlet weak var btn_ReviewOt: UIButton!
    
    let user_Type = USER_DEFAULT.value(forKey: USER_TYPE) as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if Utility.isUserLogin() {
            if user_Type == "Client" {
                self.businessProfile_Vw.isHidden = false
                self.userProfile_Vw.isHidden = false
                self.btn_ReviewOt.isHidden = true
            } else {
                self.businessProfile_Vw.isHidden = true
                self.userProfile_Vw.isHidden = false
                self.btn_ReviewOt.isHidden = false
            }
        } else {
            self.businessProfile_Vw.isHidden = true
            self.userProfile_Vw.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Settings", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        if Utility.isUserLogin() {
            self.GetProfile()
        }
    }
    
    @IBAction func btn_WalletType(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "WalletTypeVC") as! WalletTypeVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_History(_ sender: UIButton)
    {
        let vC = R.storyboard.main.historyVC()!
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Profile(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_CurrentShift(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "CurrentShiftVC") as! CurrentShiftVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Rates(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "SetRateVC") as! SetRateVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_ChangePassword(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "ChangePAssVC") as! ChangePAssVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_ReferFriend(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "ReferFriendVC") as! ReferFriendVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_PrivacyPolicy(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "TermsAndCondVC") as! TermsAndCondVC
        vC.strTitle = "Privacy Policy"
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_TermsCondition(_ sender: UIButton) {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "TermsAndCondVC") as! TermsAndCondVC
        vC.strTitle = "Terms and Conditions"
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_CustomerSupport(_ sender: UIButton)
    {
        navigateToWhatsApp()
    }
    
    @IBAction func btn_SaveCards(_ sender: UIButton)
    {
        let vc = kStoryboardMain.instantiateViewController(withIdentifier: "SaveCardVC") as! SaveCardVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_ReviewRating(_ sender: UIButton)
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "UserRatingVC") as! UserRatingVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Outlets(_ sender: UIButton)
    {
        let vC = R.storyboard.main.outletVC()!
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Logout(_ sender: UIButton)
    {
        logout()
    }
    
    @IBAction func btn_DeleteAccount(_ sender: UIButton) {
        if Utility.isUserLogin() {
            deleteAccountConfirmation()
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    func navigateToWhatsApp() {
        
        let phoneNumber =  "6582231930" // you need to change this number
        let appURL = URL(string: "https://api.whatsapp.com/send?phone=\(phoneNumber)")!
        //whatsapp://send?text=\("Hello World")
        print("\(phoneNumber)")
        
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            else {
                UIApplication.shared.openURL(appURL)
            }
        }
    }
    
    func logout() {
        let alertController = UIAlertController(title: APP_NAME, message: "Are you sure you want logout?", preferredStyle: .alert)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            UserDefaults.standard.removeObject(forKey: USER_TYPE)
            UserDefaults.standard.removeObject(forKey: STATUS)
            UserDefaults.standard.removeObject(forKey: CUSTOMERID)
            UserDefaults.standard.removeObject(forKey: CARDID)
            UserDefaults.standard.removeObject(forKey: CLIENTID)
            UserDefaults.standard.removeObject(forKey: BUSINESS_NAME)
            UserDefaults.standard.removeObject(forKey: BUSINESS_LOGO)
            UserDefaults.standard.removeObject(forKey: OUTLET_NAME)
            UserDefaults.standard.removeObject(forKey: OUTLET_IMAGE)
            UserDefaults.standard.synchronize()
            Switcher.updateRootVC()
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteAccountConfirmation() {
        let alertController = UIAlertController(title: APP_NAME, message: "Are you sure you want to delete account?", preferredStyle: .alert)
        let yesAction: UIAlertAction = UIAlertAction(title: "Yes", style: .default) { action -> Void in
            self.deleteAccount()
        }
        let noAction: UIAlertAction = UIAlertAction(title: "No", style: .cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ProfileSettingVC {
    
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
                    kappDelegate.dic_Profile = swiftyJsonVar["result"]
                    let deleteStatus = swiftyJsonVar["result"]["delete_account_button_status"].stringValue
                    if deleteStatus == "Yes" {
                        self.btn_DeleteAccountOt.isHidden = false
                    } else {
                        self.btn_DeleteAccountOt.isHidden = true
                    }
                } else {
                    print(swiftyJsonVar["result"].string ?? "")
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func deleteAccount() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.delete_Account.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    UserDefaults.standard.removeObject(forKey: USER_TYPE)
                    UserDefaults.standard.removeObject(forKey: STATUS)
                    UserDefaults.standard.removeObject(forKey: CUSTOMERID)
                    UserDefaults.standard.removeObject(forKey: CARDID)
                    UserDefaults.standard.synchronize()
                    Switcher.updateRootVC()
                } else {
                    print(swiftyJsonVar["result"].string ?? "")
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}
