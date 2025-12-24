

import UIKit
import SwiftyJSON

class ChangePAssVC: UIViewController {
    
    @IBOutlet weak var text_CurrentPa: UITextField!
    @IBOutlet weak var text_Conf: UITextField!
    @IBOutlet weak var textPass: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Change Password", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        if Utility.isUserLogin() {
            if isValidInput() {
                changeUserPassword()
            }
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    // MARK: - Validation
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        if (self.text_CurrentPa.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Current Password"
        } else if (self.textPass.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter New Password"
        } else if (self.text_Conf.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Confirm Password"
        } else if self.textPass.text! != self.text_Conf.text! {
            isValid = false
            errorMessage = "Please Enter Same Password"
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
    //MARK:API
    func changeUserPassword() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["password"]     =   self.textPass.text! as AnyObject
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["old_password"]     =   self.text_CurrentPa.text! as AnyObject

        CommunicationManager.callPostService(apiUrl: Router.change_password.url(), parameters: paramsDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"] == "1") {
                    
                    self.perform(#selector(goBackD), with: self, afterDelay: 1.0)
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: "Password Changed", on: self)
                    
                } else {
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: swiftyJsonVar["message"].stringValue, on: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    @objc func goBackD()  {
        Switcher.updateRootVC()
    }
}
