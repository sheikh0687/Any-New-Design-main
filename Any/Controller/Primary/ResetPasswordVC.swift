//
//  ResetPasswordVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 28/01/25.
//

import UIKit
import SwiftyJSON

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var txt_NewPassword: UITextField!
    @IBOutlet weak var txt_ConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Enter New Password", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_Finish(_ sender: UIButton) {
        if isValidInput() {
            checkResestPassword()
        }
    }
    
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        
        if (self.txt_NewPassword.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter New Password"
        } else if (self.txt_ConfirmPassword.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Confirm Password"
        } else if self.txt_NewPassword.text != self.txt_ConfirmPassword.text {
            isValid = false
            errorMessage = "Please Enter Same Password"
            txt_ConfirmPassword.becomeFirstResponder()
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
}

extension ResetPasswordVC {
    
    func checkResestPassword() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["user_id"]     =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["password"]    =   txt_NewPassword.text! as AnyObject?
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.reset_password.url(), parameters: paramsDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"] == "1") {
                    let vC = R.storyboard.main().instantiateViewController(withIdentifier: "PopPasswordChangedVC") as! PopPasswordChangedVC
                    vC.cloSuccess = {
                        Switcher.updateRootVC()
                    }
                    vC.modalTransitionStyle = .crossDissolve
                    vC.modalPresentationStyle = .overFullScreen
                    self.present(vC, animated: true)
                } else {
                    let message = swiftyJsonVar["result"].stringValue
                    print(message)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}
