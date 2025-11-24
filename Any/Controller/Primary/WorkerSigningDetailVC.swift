//
//  WorkerSigningDetailVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 15/10/24.
//

import UIKit
import SwiftyJSON
import DropDown

class WorkerSigningDetailVC: UIViewController {
    
    @IBOutlet weak var nrcImg: UIImageView!
    @IBOutlet weak var baristaCertImg: UIImageView!
    @IBOutlet weak var viewBarista: UIView!
    @IBOutlet weak var btn_JobTypeOt: UIButton!
    
    var arr_AllCat:[JSON] = []
    var drop = DropDown()
    
    var strJobTypeName:String = ""
    var strJobId:String = ""
    var strType:String = ""
    var imageNRCDocument:UIImage? = nil
    var imageBaristDocument:UIImage? = nil
    var workerProfile:UIImage? = nil
    var documentReq:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        WebGetJobCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Create Worker Profile", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_ProfileImg(_ sender: UIButton) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
            sender.setImage(image, for: .normal)
            workerProfile = image
        }
    }
    
    @IBAction func btn_Jobtype(_ sender: UIButton) {
        drop.anchorView = sender
        let catName = arr_AllCat.map { $0["name"].stringValue }
        drop.dataSource =  catName
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            self.strJobTypeName = item
            self.strJobId = arr_AllCat[index]["id"].stringValue
            //            self.documentReq = arr_AllCat[index]["document_requied"].stringValue
            //
            //            if documentReq == "Yes" {
            //                viewBarista.isHidden = false
            //            } else {
            //                viewBarista.isHidden = true
            //            }
        }
    }
    
    @IBAction func btn_UploadNRC(_ sender: UIButton) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
            nrcImg.image = image
            imageNRCDocument = image
        }
    }
    
    @IBAction func btn_UploadBerist(_ sender: UIButton) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
            baristaCertImg.image = image
            imageBaristDocument = image
        }
    }
    
    @IBAction func btn_Finish(_ sender: UIButton) {
        if isValidInput() {
            WebUpdateWorkerProfile()
        }
    }
    
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        if workerProfile == nil {
            isValid = false
            errorMessage = "Please Select Profile Image"
        }
//        if strJobTypeName.isEmpty {
//            isValid = false
//            errorMessage = "Please Select Job Type"
//        }  else
        
        //        else if imageNRCDocument == nil {
        //            isValid = false
        //            errorMessage = "Please Select The Document"
        //        } else if documentReq == "Yes" {
        //            if imageBaristDocument == nil {
        //                isValid = false
        //                errorMessage = "Please Select Barista Certificate"
        //            }
        //        }
        
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
}

extension WorkerSigningDetailVC {
    
    func WebGetJobCategory() {
        showProgressBar()
        let paramsDict:[String:AnyObject] = [:]
        
        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_job_type.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllCat = swiftyJsonVar["result"].arrayValue
                    let firstJobType = self.arr_AllCat[0]
                    self.strJobTypeName = firstJobType["name"].stringValue
                    self.strJobId = firstJobType["id"].stringValue
                    self.btn_JobTypeOt.setTitle(firstJobType["name"].stringValue, for: .normal)
                    print(self.arr_AllCat.count)
                } else {
                    let message = swiftyJsonVar["result"].string
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message!, on: self)
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebUpdateWorkerProfile() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["email"]     =   USER_DEFAULT.value(forKey: USEREMAIL) as AnyObject
        paramsDict["first_name"]  =   USER_DEFAULT.value(forKey: USERFIRSTNAME) as AnyObject
        paramsDict["last_name"]  =   USER_DEFAULT.value(forKey: USERLASTNAME) as AnyObject
        paramsDict["mobile"]     =   USER_DEFAULT.value(forKey: USERMOBILE) as AnyObject
        paramsDict["pay_now_number"]  =   EMPTY_STRING as AnyObject
        paramsDict["local_bank_number"]  =   EMPTY_STRING as AnyObject
        paramsDict["bank_name"]  =   EMPTY_STRING as AnyObject
        paramsDict["lat"]   =        kappDelegate.CURRENT_LAT as AnyObject
        paramsDict["lon"]  =        kappDelegate.CURRENT_LON as AnyObject
        paramsDict["register_id"]  =   "" as AnyObject?
        paramsDict["type"]     =   strType as AnyObject
        paramsDict["about_us"]  =   "1" as AnyObject?
        paramsDict["address"]  =   "1" as AnyObject?
        
        paramsDict["ios_register_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject?
        paramsDict["job_type_id"]     =   strJobId as AnyObject
        paramsDict["job_type_name"]     =   strJobTypeName as AnyObject
        
        print(paramsDict)
        
        var paramImgDict: [String : UIImage] = [:]
        paramImgDict["image"] = workerProfile
        
        print(paramImgDict)
        
        CommunicationManager.uploadImagesAndData(apiUrl: Router.update_profile_worker.url(), params: (paramsDict as! [String : String]) , imageParam: paramImgDict, videoParam: [:], parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    Utility.showAlertWithAction(withTitle: "Successfull!", message: "Your account is pending approval and you will receive notifications once you are authorized to book jobs.", delegate: self, parentViewController: self) { issy in
                        Switcher.updateRootVC()
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
    
    
    //    func WebSignUpForWorker() {
    //
    //        paramSignupDict["job_type_id"] = strJobId as AnyObject
    //        paramSignupDict["job_type_name"] = strJobTypeName as AnyObject
    //
    //        print(paramSignupDict)
    //
    //        var paramImages: [String : UIImage] = [:]
    //        paramImages["image"] = workerProfile
    ////        paramImages["nrc_document"] = imageNRCDocument
    //
    ////        paramImages["job_document"] = imageBaristDocument
    //
    //        print(paramImages)
    //
    //        showProgressBar()
    //
    //        CommunicationManager.uploadImagesAndData(apiUrl: Router.signUp.url(), params: (paramSignupDict as! [String : String]) , imageParam: paramImages, videoParam: [:], parentViewController: self, successBlock: { (responseData, message) in
    //
    //            DispatchQueue.main.async { [self] in
    //                let swiftyJsonVar = JSON(responseData)
    //                if(swiftyJsonVar["status"].stringValue == "1") {
    //                    Utility.showAlertWithAction(withTitle: "Successfull!", message: "Your account is pending approval and you will receive notifications once you are authorized to book jobs.", delegate: self, parentViewController: self) { issy in
    //                        USER_DEFAULT.set(swiftyJsonVar["result"]["type"].stringValue, forKey: USER_TYPE)
    //                        USER_DEFAULT.set(swiftyJsonVar["result"]["id"].stringValue, forKey: USERID)
    //                        USER_DEFAULT.set(swiftyJsonVar["status"].stringValue, forKey: STATUS)
    //                        Switcher.updateRootVC()
    //                    }
    //                } else {
    //                    let message = swiftyJsonVar["message"].stringValue
    //                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message, on: self)
    //                }
    //                self.hideProgressBar()
    //            }
    //        },failureBlock: { (error : Error) in
    //            self.hideProgressBar()
    //            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
    //        })
    //    }
}
