//
//  AddAdminVC.swift
//  Any
//
//  Created by mac on 02/06/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import DropDown

class AddAdminVC: UIViewController {

    @IBOutlet weak var text_Last: UITextField!
    @IBOutlet weak var text_First: UITextField!
    
    var strType:String! = "OutletAdmin"

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: strType, CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }

    @IBAction func add(_ sender: Any) {
   
        if isValidInputSignup() {
            CheckEmailStatus()
        }
    }
    func isValidInputSignup() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        if (self.text_First.text?.isEmpty)!{
            isValid = false
            errorMessage = "Please Enter First Name"
        }   else if (self.text_Last.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Last Name"
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
    func CheckEmailStatus() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["first_name"]     =   self.text_First.text! as AnyObject
        paramsDict["last_name"]  =   self.text_Last.text! as AnyObject
        paramsDict["type"]     =   strType as AnyObject

        print(paramsDict)

        CommunicationManager.callPostService(apiUrl: Router.add_OutletAdmin_AuthrisedApprover.url(), parameters: paramsDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"] == "1") {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let message = swiftyJsonVar["message"].stringValue
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message, on: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}
