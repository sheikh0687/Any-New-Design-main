//
//  ClientSigningDetailVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 04/02/25.
//

import UIKit
import SwiftyJSON

class ClientSigningDetailVC: UIViewController {
    
    @IBOutlet weak var txt_BusinessName: SloyTextField!
    @IBOutlet weak var txt_RegisterNumber: SloyTextField!
    @IBOutlet weak var txt_BusinessAddress: SloyTextField!
    @IBOutlet weak var txt_MobileNumber: SloyTextField!
    @IBOutlet weak var img_BusinessLogo: UIImageView!
    
    @IBOutlet weak var btn_Cou: UIButton!
    
    var strType:String = ""
    var strMobileNum:String = ""
    var imageBuisnesslogo:UIImage? = nil
    var strCode:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txt_MobileNumber.text = self.strMobileNum
        btn_Cou.setTitle("+\(strCode)", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Create Business Profile", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: WHITE_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_UploadPhoto(_ sender: UIButton) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
            img_BusinessLogo.image = image
            imageBuisnesslogo = image
        }
    }
    
    @IBAction func btn_Finish(_ sender: UIButton) {
        if isValidInput() {
            WebUpdateClientProfile()
        }
    }
    
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        if (txt_BusinessName.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Busines Name"
        }  else if (self.txt_RegisterNumber.text?.isEmpty)!{
            isValid = false
            errorMessage = "Please Enter Register Number"
        } else if (txt_BusinessAddress.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Business Address"
            txt_BusinessAddress.becomeFirstResponder()
        } else if imageBuisnesslogo == nil {
            isValid = false
            errorMessage = "Please Select Business Logo"
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
}

extension ClientSigningDetailVC {
    
    func GetClientInstruction() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["country_id"]  =   USER_DEFAULT.value(forKey: COUNTRYID) as AnyObject
        
        CommunicationManager.callPostApi(apiUrl: Router.get_country_details.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let obj = swiftyJsonVar["result"]
                    self.txt_RegisterNumber.placeholder = obj["client_document"].stringValue
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
        
    func WebUpdateClientProfile() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["email"]     =   USER_DEFAULT.value(forKey: USEREMAIL) as AnyObject
        paramsDict["first_name"]  =   USER_DEFAULT.value(forKey: USERFIRSTNAME) as AnyObject
        paramsDict["last_name"]  =   USER_DEFAULT.value(forKey: USERLASTNAME) as AnyObject
        paramsDict["business_name"]  =   self.txt_BusinessName.text! as AnyObject
        paramsDict["une_register_number"]  =   self.txt_RegisterNumber.text! as AnyObject
        paramsDict["business_address"]  =   self.txt_BusinessAddress.text! as AnyObject
        paramsDict["lat"]   =        kappDelegate.CURRENT_LAT as AnyObject
        paramsDict["lon"]  =        kappDelegate.CURRENT_LON as AnyObject
        paramsDict["register_id"]  =   "" as AnyObject?
        paramsDict["type"]     =   strType as AnyObject
        paramsDict["mobile"]     =   txt_MobileNumber.text! as AnyObject
        paramsDict["about_us"]  =   "1" as AnyObject?
        paramsDict["ios_register_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject?
        
        print(paramsDict)
        
        var paramImgDict: [String : UIImage] = [:]
        paramImgDict["business_logo"] = imageBuisnesslogo
        
        print(paramImgDict)
        
        CommunicationManager.uploadImagesAndData(apiUrl: Router.update_profile_client.url(), params: (paramsDict as! [String : String]) , imageParam: paramImgDict, videoParam: [:], parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let vC = R.storyboard.main().instantiateViewController(withIdentifier: "RegistrationSuccessVC") as! RegistrationSuccessVC
                    vC.imageBuisnesslogo = self.imageBuisnesslogo
                    vC.strBusinessName = self.txt_BusinessName.text
                    self.navigationController?.pushViewController(vC, animated: true)
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
