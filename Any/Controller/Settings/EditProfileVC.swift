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
    var addressLat:String = ""
    var addressLon:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryList.delegate = self
        
        if let mobileCode = USER_DEFAULT.value(forKey: MobileCode) as? String {
            btn_Cou.setTitle("+\(mobileCode)", for: .normal)
        } else {
            btn_Cou.setTitle("+65", for: .normal)
        }
        
        let locale: NSLocale = NSLocale.current as NSLocale
        let _: String? = locale.countryCode
        
        if Utility.isUserLogin() {
            
            if let userType = USER_DEFAULT.value(forKey: USER_TYPE) as? String {
                strType = userType
            }
            
            if strType == "Client" {
                
                view_jobType.isHidden = true
                view_Nrc.isHidden = true
                view_Basrita.isHidden = true
                view_Buismesslogo.isHidden = false
                localBankDetails.isHidden = true
                
                let profile = kappDelegate.dic_Profile
                
                text_First?.text        = profile?["first_name"].string ?? ""
                text_Last?.text         = profile?["last_name"].string ?? ""
                text_Mobile?.text       = profile?["mobile"].string ?? ""
                text_Mail?.text         = profile?["email"].string ?? ""
                text_BusName?.text      = profile?["business_name"].string ?? ""
                textbuinseeAddre?.text  = profile?["business_address"].string ?? ""
                text_Une?.text          = profile?["une_register_number"].string ?? ""
                self.addressLat         = profile?["lat"].string ?? ""
                self.addressLon         = profile?["lon"].string ?? ""
                
                let businessname = profile?["business_name"].string ?? ""
                USER_DEFAULT.set(businessname, forKey: BUSINESS_NAME)
                
                let businessLogoURL = profile?["business_logo"].string ?? ""
                if businessLogoURL.isEmpty || businessLogoURL == Router.BASE_IMAGE_URL {
                    img_Buinsesslogo.image = UIImage(named: "placeholder1")
                } else {
                    img_Buinsesslogo.sd_setImage(
                        with: URL(string: businessLogoURL),
                        placeholderImage: UIImage(named: "placeholder1")
                    )
                }
                
                let profileImageURL = profile?["image"].string ?? ""
                if profileImageURL.isEmpty || profileImageURL == Router.BASE_IMAGE_URL {
                    img_Profile.image = UIImage(named: "placeholder1")
                } else {
                    img_Profile.sd_setImage(
                        with: URL(string: profileImageURL),
                        placeholderImage: UIImage(named: "placeholder1")
                    )
                }
                
                self.textbuinseeAddre.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPicker))
                textbuinseeAddre.addGestureRecognizer(tapGesture)
                
            } else {
                
                text_BusName.isHidden = true
                text_Une.isHidden = true
                textbuinseeAddre.isHidden = true
                view_Buismesslogo.isHidden = true
                view_jobType.isHidden = false
                
                let profile = kappDelegate.dic_Profile
                
                // MARK: - Safe Text Assignments
                text_First?.text        = profile?["first_name"].string ?? ""
                text_Last?.text         = profile?["last_name"].string ?? ""
                text_Mobile?.text       = profile?["mobile"].string ?? ""
                txt_PayNowNumber?.text  = profile?["pay_now_number"].string ?? ""
                txt_BankName?.text      = profile?["bank_name"].string ?? ""
                txt_BankNumber?.text    = profile?["local_bank_number"].string ?? ""
                text_Mail?.text         = profile?["email"].string ?? ""
                
                strJobId                = profile?["job_type_id"].string ?? ""
                strJobTypeName          = profile?["job_type_name"].string ?? ""
                btn_Jobtype.setTitle(strJobTypeName, for: .normal)
                
                
                // MARK: - Safe Image Loading (NO helper function)
                
                // Profile Image
                let profileImageURL = profile?["image"].string ?? ""
                if profileImageURL.isEmpty || profileImageURL == Router.BASE_IMAGE_URL {
                    img_Profile.image = UIImage(named: "placeholder1")
                } else {
                    img_Profile.sd_setImage(
                        with: URL(string: profileImageURL),
                        placeholderImage: UIImage(named: "placeholder1")
                    )
                }
                
                // Job Document Image
                let jobDocURL = profile?["job_document"].string ?? ""
                if jobDocURL.isEmpty || jobDocURL == Router.BASE_IMAGE_URL {
                    img_Berista.image = UIImage(named: "upload_image")
                } else {
                    img_Berista.sd_setImage(
                        with: URL(string: jobDocURL),
                        placeholderImage: UIImage(named: "upload_image")
                    )
                }
                
                // NRC Document Image
                let nrcDocURL = profile?["nrc_document"].string ?? ""
                if nrcDocURL.isEmpty || nrcDocURL == Router.BASE_IMAGE_URL {
                    img_Nrc.image = UIImage(named: "upload_image")
                } else {
                    img_Nrc.sd_setImage(
                        with: URL(string: nrcDocURL),
                        placeholderImage: UIImage(named: "upload_image")
                    )
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
    
    @objc func addPicker()
    {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "AddressPickerVC") as! AddressPickerVC
        vC.locationPickedBlock = { [weak self] cordinationVal, latVal, lonVal, addressVal in
            guard let self = self else { return }
            self.textbuinseeAddre.text = addressVal
            self.addressLat = String(latVal)
            self.addressLon = String(lonVal)
        }
        self.present(vC, animated: true, completion: nil)
        
    }
    
    override func rightClick() {
        let vC = R.storyboard.main.profileSettingVC()!
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
        
        CommunicationManager.callPostService(apiUrl: Router.get_country_details.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
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
        paramsDict["lat"]   =        addressLat as AnyObject
        paramsDict["lon"]  =        addressLon as AnyObject
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
