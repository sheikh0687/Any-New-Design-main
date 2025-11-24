//
//  EditProfileVC.swift
//  Any
//
//  Created by mac on 18/05/23.
//

import UIKit
import SwiftyJSON
import DropDown
import AuthenticationServices
import CoreTelephony
import SDWebImage

class EditProfileVC: UIViewController  {
    
    @IBOutlet weak var img_Berista: UIImageView!
    @IBOutlet weak var view_Basrita: UIView!
    @IBOutlet weak var view_Nrc: UIView!
    @IBOutlet weak var view_jobType: UIView!
    @IBOutlet weak var text_First: SloyTextField!
    
    @IBOutlet weak var view_Pr: UIView!
    @IBOutlet weak var view_Buismesslogo: UIView!
    @IBOutlet weak var btn_Jobtype: UIButton!
    @IBOutlet weak var img_Nrc: UIImageView!
    @IBOutlet weak var img_Profile: UIImageView!
    @IBOutlet weak var img_Buinsesslogo: UIImageView!
    @IBOutlet weak var btn_Upload: UIButton!
    @IBOutlet weak var text_BusName: SloyTextField!
    @IBOutlet weak var text_Une: SloyTextField!
    @IBOutlet weak var textbuinseeAddre: SloyTextField!
    @IBOutlet weak var btn_Cou: UIButton!
    @IBOutlet weak var text_Last: UITextField!
    @IBOutlet weak var text_Mobile: UITextField!
    @IBOutlet weak var text_Mail: UITextField!
    @IBOutlet weak var localBankDetails: UIStackView!
    @IBOutlet weak var txt_PayNowNumber: SloyTextField!
    @IBOutlet weak var txt_BankNumber: SloyTextField!
    @IBOutlet weak var txt_BankName: SloyTextField!
    @IBOutlet weak var lbl_DoxText: UILabel!
    
    var countryList = CountryList()
    var imageBuisnesslogo:UIImage? = nil
    //    var profileImg: UIImage? = nil
    var strCCode:String! = "65"
    var drop = DropDown()
    var arr_AllCat:[JSON] = []
    var strType:String! = ""
    var imgBarista:UIImage? = nil
    var strJobId:String! = "1"
    var strJobTypeName:String! = "F&B"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryList.delegate = self
        
        btn_Cou.setTitle("+\(USER_DEFAULT.value(forKey: MobileCode) as? String ?? "65")", for: .normal)
        
        let locale: NSLocale = NSLocale.current as NSLocale
        let country: String? = locale.countryCode
        
        if Utility.isUserLogin() {
            strType = (USER_DEFAULT.value(forKey: USER_TYPE) as! String)
            
            if strType == "Client" {
                
                view_jobType.isHidden = true
                view_Nrc.isHidden = true
                view_Basrita.isHidden = true
                view_Buismesslogo.isHidden = false
                localBankDetails.isHidden = true
                
                text_First.text = kappDelegate.dic_Profile["first_name"].stringValue
                text_Last.text = kappDelegate.dic_Profile["last_name"].stringValue
                text_Mobile.text = kappDelegate.dic_Profile["mobile"].stringValue
                text_Mail.text = kappDelegate.dic_Profile["email"].stringValue
                text_BusName.text = kappDelegate.dic_Profile["business_name"].stringValue
                text_Une.text = kappDelegate.dic_Profile["une_register_number"].stringValue
                textbuinseeAddre.text = kappDelegate.dic_Profile["business_address"].stringValue
                
                if Router.BASE_IMAGE_URL != kappDelegate.dic_Profile["business_logo"].stringValue {
                    self.img_Buinsesslogo.sd_setImage(with: URL.init(string: (kappDelegate.dic_Profile["business_logo"].stringValue)), placeholderImage: UIImage.init(named: "placeholder1"), options: SDWebImageOptions(rawValue: 1), completed: nil)
                } else {
                    self.img_Buinsesslogo.image = nil
                }
                
                if Router.BASE_IMAGE_URL != kappDelegate.dic_Profile["image"].stringValue {
                    self.img_Profile.sd_setImage(with: URL.init(string: (kappDelegate.dic_Profile["image"].stringValue)), placeholderImage: UIImage.init(named: "placeholder1"), options: SDWebImageOptions(rawValue: 1), completed: nil)
                } else {
                    self.img_Profile.image = nil
                }
                
            } else {
                
                text_BusName.isHidden = true
                text_Une.isHidden = true
                textbuinseeAddre.isHidden = true
                view_Buismesslogo.isHidden = true
                view_jobType.isHidden = false
                
                text_First.text = kappDelegate.dic_Profile["first_name"].stringValue
                text_Last.text = kappDelegate.dic_Profile["last_name"].stringValue
                text_Mobile.text = kappDelegate.dic_Profile["mobile"].stringValue
                txt_PayNowNumber.text = kappDelegate.dic_Profile["pay_now_number"].stringValue
                txt_BankName.text = kappDelegate.dic_Profile["bank_name"].stringValue
                txt_BankNumber.text = kappDelegate.dic_Profile["local_bank_number"].stringValue
                
                text_Mail.text = kappDelegate.dic_Profile["email"].stringValue
                strJobId = kappDelegate.dic_Profile["job_type_id"].stringValue
                strJobTypeName = kappDelegate.dic_Profile["job_type_name"].stringValue
                btn_Jobtype.setTitle(kappDelegate.dic_Profile["job_type_name"].stringValue, for: .normal)
                
                if Router.BASE_IMAGE_URL != kappDelegate.dic_Profile["image"].stringValue {
                    self.img_Profile.sd_setImage(with: URL.init(string: (kappDelegate.dic_Profile["image"].stringValue)), placeholderImage: UIImage.init(named: "placeholder1"), options: SDWebImageOptions(rawValue: 1), completed: nil)
                } else {
                    self.img_Profile.image = nil
                }
                
                if Router.BASE_IMAGE_URL != kappDelegate.dic_Profile["job_document"].stringValue
                {
                    self.img_Berista.sd_setImage(with: URL.init(string: (kappDelegate.dic_Profile["job_document"].stringValue)), placeholderImage: UIImage.init(named: "upload_image"), options: SDWebImageOptions(rawValue: 1), completed: nil)
                } else {
                    self.img_Berista.image = nil
                }
                
                if Router.BASE_IMAGE_URL != kappDelegate.dic_Profile["nrc_document"].stringValue {
                    
                    self.img_Nrc.sd_setImage(with: URL.init(string: (kappDelegate.dic_Profile["nrc_document"].stringValue)), placeholderImage: UIImage.init(named: "upload_image"), options: SDWebImageOptions(rawValue: 1), completed: nil)

                } else {
                    self.img_Nrc.image = nil
                }
            }
        } else {
            text_BusName.isHidden = true
            text_Une.isHidden = true
            textbuinseeAddre.isHidden = true
            view_Buismesslogo.isHidden = true
            view_jobType.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if strType == "Client" {
            self.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = true
            setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Business Profile", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        } else {
            self.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = false
            setNavigationBarItem(LeftTitle: "My Profile", LeftImage: "", CenterTitle: "", CenterImage: "", RightTitle: "", RightImage: "menu", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        }
        if Utility.isUserLogin() {
            WebGetCategoryjobType()
            GetClientInstruction()
        }
    }
    
    override func rightClick() {
        let vC = R.storyboard.main().instantiateViewController(withIdentifier: "ProfileSettingVC") as! ProfileSettingVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func tapedCountrCode(_ sender: Any) {
        let navController = UINavigationController(rootViewController: countryList)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func selectJobType(_ sender: UIButton) {
        
        drop.anchorView = sender
        let catName = arr_AllCat.map({$0["name"].stringValue})
        drop.dataSource =  catName
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            self.btn_Jobtype.setTitle(item, for: .normal)
            self.strJobTypeName = item
            self.strJobId = arr_AllCat[index]["id"].stringValue
            let documentReq = arr_AllCat[index]["document_requied"].stringValue
            
            if documentReq == "Yes" {
                view_Basrita.isHidden = false
            } else {
                view_Basrita.isHidden = true
            }
        }
    }
    
    @IBAction func editProfileIm(_ sender: UIButton) {
        if Utility.isUserLogin() {
            CameraHandler.sharedInstance.showActionSheet(vc: self, sender: sender)
            CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
                img_Profile.image = image
            }
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    @IBAction func nrcImage(_ sender: Any) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
            img_Nrc.image = image
        }
    }
    
    @IBAction func beristaImage(_ sender: Any) {
        CameraHandler.sharedInstance.showActionSheet(vc: self)
        CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
            img_Berista.image = image
            imgBarista = image
        }
    }
    
    @IBAction func uploadIMage(_ sender: Any) {
        if Utility.isUserLogin() {
            CameraHandler.sharedInstance.showActionSheet(vc: self)
            CameraHandler.sharedInstance.imagePickedBlock = { [self] (image) in
                img_Buinsesslogo.image = image
                imageBuisnesslogo = image
            }
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    @IBAction func signUppp(_ sender: Any) {
        if Utility.isUserLogin() {
            if strType == "Client" {
                if isValidInput() {
                    WebUpdateClientProfile()
                }
            } else {
                if isValidInputForWirker() {
                    WebUpdateWorkerProfile()
                }
            }
            
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    func countryName(from countryCode: String) -> String {
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            // Country name was found
            return name
        } else {
            // Country name cannot be found
            return countryCode
        }
    }
}


// MARK: - Validation
extension EditProfileVC {
    
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        
        if (self.text_First.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter First Name"
        } else if (self.text_Last.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Last Name"
        } else if (self.text_BusName.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Business Name"
        } else if (self.text_Une.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter UNE/Register Number"
        } else if (self.textbuinseeAddre.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Business Address"
        } else if (self.text_Mobile.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Mobile Number"
        } else if !(GlobalConstant.isValidEmail(text_Mail.text!)){
            isValid = false
            errorMessage = "Please Enter Valid Email"
            text_Mail.becomeFirstResponder()
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
    
    func isValidInputForWirker() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        
        if (self.text_First.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter First Name"
        } else if (self.text_Last.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Last Name"
        } else if (self.text_Mobile.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Mobile Number"
        } else if !(GlobalConstant.isValidEmail(text_Mail.text!)){
            isValid = false
            errorMessage = "Please Enter Valid Email"
            text_Mail.becomeFirstResponder()
        }  else if (self.text_Mobile.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Mobile Number"
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
}

// MARK: - Api Calling
extension EditProfileVC {
    
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
                    print(obj["client_document"].stringValue)
                    self.text_Une.placeholder = obj["client_document"].stringValue
                    self.lbl_DoxText.text = obj["worker_document"].stringValue
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
    
    func WebGetCategoryjobType() {
        showProgressBar()
        let paramsDict:[String:AnyObject] = [:]
        
        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_job_type.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllCat = swiftyJsonVar["result"].arrayValue
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
    
    func WebUpdateClientProfile() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["email"]     =   self.text_Mail.text! as AnyObject
        paramsDict["first_name"]  =   self.text_First.text! as AnyObject
        paramsDict["last_name"]  =   self.text_Last.text! as AnyObject
        paramsDict["business_name"]  =   self.text_BusName.text! as AnyObject
        paramsDict["une_register_number"]  =   self.text_Une.text! as AnyObject
        paramsDict["business_address"]  =   self.textbuinseeAddre.text! as AnyObject
        paramsDict["lat"]   =        kappDelegate.CURRENT_LAT as AnyObject
        paramsDict["lon"]  =        kappDelegate.CURRENT_LON as AnyObject
        paramsDict["register_id"]  =   "" as AnyObject?
        paramsDict["type"]     =   strType as AnyObject
        paramsDict["mobile"]     =   self.text_Mobile.text! as AnyObject
        paramsDict["mobile_witth_country_code"]     =  strCCode + self.text_Mobile.text! as AnyObject
        paramsDict["mobile_with_code"]     =  strCCode + self.text_Mobile.text! as AnyObject
        paramsDict["about_us"]  =   "1" as AnyObject?
        paramsDict["ios_register_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject?
        
        print(paramsDict)
        
        var paramImgDict: [String : UIImage] = [:]
        paramImgDict["business_logo"] = img_Buinsesslogo.image
        paramImgDict["image"] = img_Profile.image
        
        print(paramImgDict)
        
        CommunicationManager.uploadImagesAndData(apiUrl: Router.update_profile_client.url(), params: (paramsDict as! [String : String]) , imageParam: paramImgDict, videoParam: [:], parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    USER_DEFAULT.set("\(self.text_First.text!) \(self.text_Last.text!)", forKey: USER_NAME)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["request_payment_type"].stringValue, forKey: PAYMENT_TYPE)
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: "Your Profile Updated Successfully", on: self)
                    Switcher.updateRootVC()
                    
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
    
    func WebUpdateWorkerProfile() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["email"]     =   self.text_Mail.text! as AnyObject
        paramsDict["first_name"]  =   self.text_First.text! as AnyObject
        paramsDict["last_name"]  =   self.text_Last.text! as AnyObject
        paramsDict["pay_now_number"]  =   txt_PayNowNumber.text! as AnyObject
        paramsDict["local_bank_number"]  =   txt_BankNumber.text! as AnyObject
        paramsDict["bank_name"]  =   txt_BankName.text! as AnyObject
        paramsDict["lat"]   =        kappDelegate.CURRENT_LAT as AnyObject
        paramsDict["lon"]  =        kappDelegate.CURRENT_LON as AnyObject
        paramsDict["register_id"]  =   "" as AnyObject?
        paramsDict["type"]     =   strType as AnyObject
        paramsDict["mobile"]     =   self.text_Mobile.text! as AnyObject
        paramsDict["mobile_witth_country_code"]     =  strCCode + self.text_Mobile.text! as AnyObject
        paramsDict["mobile_with_code"]     =  strCCode + self.text_Mobile.text! as AnyObject
        paramsDict["about_us"]  =   "1" as AnyObject?
        paramsDict["address"]  =   "1" as AnyObject?
        
        paramsDict["ios_register_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject?
        paramsDict["job_type_id"]     =   strJobId as AnyObject
        paramsDict["job_type_name"]     =   strJobTypeName as AnyObject
        
        print(paramsDict)
        
        var paramImgDict: [String : UIImage] = [:]
        paramImgDict["nrc_document"] = img_Nrc.image
        paramImgDict["image"] = img_Profile.image
        paramImgDict["job_document"] = img_Berista.image
        
        print(paramImgDict)
        
        CommunicationManager.uploadImagesAndData(apiUrl: Router.update_profile_worker.url(), params: (paramsDict as! [String : String]) , imageParam: paramImgDict, videoParam: [:], parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    USER_DEFAULT.set("\(self.text_First.text!) \(self.text_Last.text!)", forKey: USER_NAME)
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: "Your Profile Updated Successfully", on: self)
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

extension EditProfileVC:CountryListDelegate {
    
    func selectedCountry(country: Country) {
        strCCode = "\(country.phoneExtension)"
        btn_Cou.setTitle("\(country.countryCode) +\(strCCode!)", for: .normal)
    }
}

func countryCode(from countryName: String) -> String? {
    return NSLocale.isoCountryCodes.first { (code) -> Bool in
        let name = NSLocale.current.localizedString(forRegionCode: code)
        return name == countryName
    }
}
