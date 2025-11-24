//
//  AddOutletVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 17/11/25.
//

import UIKit
import SwiftyJSON

class AddOutletVC: UIViewController {

    @IBOutlet weak var txt_OutletName: UITextField!
    @IBOutlet weak var txt_OuletAddress: UITextField!
    @IBOutlet weak var img_BusinessLogo: UIImageView!
    
    var imageBuisnesslogo:UIImage? = nil
    
    var outletName:String = ""
    var outletAddress:String = ""
    var outletImage:String = ""
    var strOutletiD:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isComeOutlet {
            self.txt_OutletName.text = self.outletName
            self.txt_OuletAddress.text = self.outletAddress
            
            if Router.BASE_IMAGE_URL != outletImage {
                Utility.downloadImageBySDWebImage(outletImage) { image, error in
                    if error == nil {
                        self.img_BusinessLogo.image = image
                        self.imageBuisnesslogo = image
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Add Outlet", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_UploadPhoto(_ sender: UIButton) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
            img_BusinessLogo.image = image
            imageBuisnesslogo = image
        }
    }
    
    @IBAction func btn_AddOutlet(_ sender: UIButton) {
        if isValidInput() {
            WebAddOutlet()
        }
    }
}

extension AddOutletVC {
    
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        if (txt_OutletName.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Outlet Name"
        }  else if (self.txt_OuletAddress.text?.isEmpty)!{
            isValid = false
            errorMessage = "Please Enter Outlet Address"
        } else if imageBuisnesslogo == nil {
            isValid = false
            errorMessage = "Please Select Outlet Logo"
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }

    func WebAddOutlet() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        if isComeOutlet {
            paramsDict["user_id"]  = strOutletiD as AnyObject
        } else {
            paramsDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        }
        paramsDict["business_name"]     =   txt_OutletName.text as AnyObject
        paramsDict["business_address"]  =   txt_OuletAddress.text as AnyObject
        
        print(paramsDict)
        
        var paramImgDict: [String : UIImage] = [:]
        paramImgDict["business_logo"] = imageBuisnesslogo
        
        print(paramImgDict)
        
        CommunicationManager.uploadImagesAndData (
            apiUrl: Router.add_UpdateOutlet.url(),
            params: (paramsDict as! [String : String]),
            imageParam: paramImgDict,
            videoParam: [:],
            parentViewController: self,
            successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    Utility.showAlertWithAction(withTitle: APPNAME, message: isComeOutlet ? "Outlet updated successfully!" : "Outlet added successfully!",  delegate: nil, parentViewController: self) { bool in
                        self.navigationController?.popViewController(animated: true)
                    }
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
