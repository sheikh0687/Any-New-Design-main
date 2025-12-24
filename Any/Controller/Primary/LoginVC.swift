

import UIKit
import SwiftyJSON
import CountryPickerView
import DropDown

class LoginVC: UIViewController {
    
    // New Login Outlets
    @IBOutlet weak var txt_LoginEmail: UITextField!
    @IBOutlet weak var txt_LoginPassword: UITextField!
    @IBOutlet weak var btnEye: UIButton!
    
    // New Ui Outlets
    @IBOutlet weak var login_View: UIView!
    @IBOutlet weak var signUp_View: UIView!
    @IBOutlet weak var lbl_LoginVw: UILabel!
    @IBOutlet weak var lbl_SignUpVw: UILabel!
    
    @IBOutlet weak var btn_CheckLoginOt: UIButton!
    @IBOutlet weak var btn_CheckSignupOt: UIButton!
    
    // New Signup Outlets
    @IBOutlet weak var txt_SignupFirstName: SloyTextField!
    @IBOutlet weak var txt_SignupLastName: SloyTextField!
    @IBOutlet weak var txt_SignupEmail: SloyTextField!
    @IBOutlet weak var txt_SignupMobile: UITextField!
    @IBOutlet weak var txt_SignupPassword: SloyTextField!
    @IBOutlet weak var txt_SignupConfirmPassword: SloyTextField!

    @IBOutlet weak var btn_Cou: UIButton!
    
    @IBOutlet weak var lbl_TermCondition: UILabel!
    @IBOutlet weak var btn_SkipOt: UIButton!
    @IBOutlet weak var btn_CountryListOt: UIButton!

    var strCCode:String! = "65"
    var countryList = CountryList()
    var strType = ""
    var strOtp = ""
    var strChekc = ""
    var iconClick = true
    var strCountryName: String = ""
    var strCountryiD:String = ""
    
    var drop = DropDown()
    var arr_CountryList: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryList.delegate = self
        
        print(strCCode ?? "")
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(termsAndCondition))
        
        lbl_TermCondition.isUserInteractionEnabled = true
        lbl_TermCondition.addGestureRecognizer(tapGesture)
        WebGetCountryList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        signUp_View.isHidden = false
        login_View.isHidden = true
        btn_CheckSignupOt.setTitleColor(.black, for: .normal)
        btn_CheckLoginOt.setTitleColor(.darkGray, for: .normal)
        lbl_SignUpVw.isHidden = false
        lbl_LoginVw.isHidden = true
        self.btn_SkipOt.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func termsAndCondition() {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "TermsAndCondVC") as! TermsAndCondVC
        kappDelegate.strTitle = "Terms and Conditions"
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btn_Skip(_ sender: UIButton) {
        let vc = Mainboard.instantiateViewController(withIdentifier: "UserTabBar") as! UserTabBar
        let navigation = UINavigationController.init(rootViewController: vc)
        navigation.isNavigationBarHidden = true
        APP_DELEGATE.window?.rootViewController = navigation
        APP_DELEGATE.window?.makeKeyAndVisible()
    }
    
    @IBAction func check_LOGIN(_ sender: Any) {
        login_View.isHidden = false
        signUp_View.isHidden = true
        btn_CheckLoginOt.setTitleColor(.black, for: .normal)
        btn_CheckSignupOt.setTitleColor(.darkGray, for: .normal)
        lbl_LoginVw.isHidden = false
        lbl_SignUpVw.isHidden = true
        self.btn_SkipOt.isHidden = false
    }
    
    @IBAction func eyeShow(_ sender: Any) {
        if(iconClick == true) {
            txt_LoginPassword.isSecureTextEntry = false
            btnEye.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        } else {
            txt_LoginPassword.isSecureTextEntry = true
            btnEye.setImage(UIImage.init(systemName: "eye"), for: .normal)
        }
        iconClick = !iconClick
    }
    
    @IBAction func check_SIGNUP(_ sender: Any) {
        signUp_View.isHidden = false
        login_View.isHidden = true
        btn_CheckSignupOt.setTitleColor(.black, for: .normal)
        btn_CheckLoginOt.setTitleColor(.darkGray, for: .normal)
        lbl_SignUpVw.isHidden = false
        lbl_LoginVw.isHidden = true
        self.btn_SkipOt.isHidden = true
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        if isValidInput() {
            CheckEmailStatus()
        }
    }
    
    @IBAction func btnForgotPassword(_ sender: UIButton) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func checkUncheckk(_ sender: UIButton) {
        
        if sender.isSelected {
            sender.isSelected = false
            strChekc = ""
            sender.setImage(UIImage.init(named: "RectangleUncheck"), for: .normal)
        } else {
            strChekc = "df"
            sender.isSelected = true
            sender.setImage(UIImage.init(named: "RectangleChecked"), for: .normal)
        }
    }
    
    @IBAction func btn_SelectCountry(_ sender: UIButton) {
        drop.anchorView = sender
        let catName = arr_CountryList.map { $0["name"].stringValue }
        drop.dataSource =  catName
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            self.strCountryName = item
            self.strCountryiD = arr_CountryList[index]["id"].stringValue
        }
    }
    
    @IBAction func btn_Signup(_ sender: UIButton) {
        if isValidSignupInput() {
            WebVerifyNumber()
        }
    }
    
    @IBAction func tapedCountrCode(_ sender: Any) {
        let navController = UINavigationController(rootViewController: countryList)
        self.present(navController, animated: true, completion: nil)
    }
}

extension LoginVC:CountryListDelegate {
    
    func selectedCountry(country: Country) {
        
        strCCode = "\(country.phoneExtension)"
        btn_Cou.setTitle("\(country.countryCode) +\(strCCode!)", for: .normal)
        print(strCCode!)
        
        USER_DEFAULT.set(strCCode, forKey: MobileCode)
        print(USER_DEFAULT.value(forKey: MobileCode)!)
    }
}

// MARK: - Validation
extension LoginVC {
    
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        if !(GlobalConstant.isValidEmail(txt_LoginEmail.text!)) {
            isValid = false
            errorMessage = "Please Enter Valid Email"
        }  else if (self.txt_LoginPassword.text?.isEmpty)!{
            isValid = false
            errorMessage = "Please Enter Password"
            txt_LoginPassword.becomeFirstResponder()
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
    
    func isValidSignupInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        
        if (self.txt_SignupFirstName.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter First Name"
        } else if (self.txt_SignupLastName.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Last Name"
        } else if (self.txt_SignupMobile.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Mobile Number"
        } else if !(GlobalConstant.isValidEmail(txt_SignupEmail.text!)){
            isValid = false
            errorMessage = "Please Enter Valid Email"
            txt_SignupEmail.becomeFirstResponder()
        } else if (self.txt_SignupPassword.text?.isEmpty)!{
            isValid = false
            errorMessage = "Please Enter Password"
            txt_SignupPassword.becomeFirstResponder()
        } else if (self.txt_SignupConfirmPassword.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Confirm Password"
            txt_SignupConfirmPassword.becomeFirstResponder()
        } else if self.txt_SignupPassword.text != self.txt_SignupConfirmPassword.text {
            isValid = false
            errorMessage = "Please Enter Same Password"
            txt_SignupConfirmPassword.becomeFirstResponder()
        } else if self.strChekc.isEmpty {
            isValid = false
            errorMessage = "Please Read The Terms and Condition"
        }
        
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
    
}

// MARK: - Network Calling
extension LoginVC {
    
    func WebGetCountryList() {
        showProgressBar()
        let paramsDict:[String:AnyObject] = [:]
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_country_list.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_CountryList = swiftyJsonVar["result"].arrayValue
                    self.btn_CountryListOt.setTitle(self.arr_CountryList[0]["name"].stringValue, for: .normal)
                    self.strCountryName = self.arr_CountryList[0]["name"].stringValue
                    self.strCountryiD = self.arr_CountryList[0]["id"].stringValue
                    print(self.arr_CountryList.count)
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
    
    func CheckEmailStatus() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["email"]     =   self.txt_LoginEmail.text! as AnyObject
        paramsDict["password"]  =   self.txt_LoginPassword.text! as AnyObject
        paramsDict["ios_register_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject?
        paramsDict["register_id"]     =   "" as AnyObject
        paramsDict["type"]     =   strType as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.logIn.url(), parameters: paramsDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"] == "1") {
                    print(swiftyJsonVar)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["id"].stringValue, forKey: USERID)
                    USER_DEFAULT.set(swiftyJsonVar["status"].stringValue, forKey: STATUS)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["type"].stringValue, forKey: USER_TYPE)
                    USER_DEFAULT.set("\(swiftyJsonVar["result"]["first_name"].stringValue) \(swiftyJsonVar["result"]["last_name"].stringValue)", forKey: USER_NAME)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["request_payment_type"].stringValue, forKey: PAYMENT_TYPE)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["customer_id"].stringValue, forKey: CUSTOMERID)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["card_id"].stringValue, forKey: CARDID)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["email"].stringValue, forKey: USEREMAIL)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["mobile"].stringValue, forKey: USERMOBILE)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["first_name"].stringValue, forKey: USERFIRSTNAME)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["last_name"].stringValue, forKey: USERLASTNAME)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["country_id"].stringValue, forKey: COUNTRYID)
                    
                    USER_DEFAULT.set(swiftyJsonVar["result"]["currency_symbol"].stringValue, forKey: CURRENCY_SYMBOL)
                    
                    USER_DEFAULT.set(swiftyJsonVar["result"]["id"].stringValue, forKey: CLIENTID)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["business_name"].stringValue, forKey: BUSINESS_NAME)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["business_logo"].stringValue, forKey: BUSINESS_LOGO)
                    
                    USER_DEFAULT.set(swiftyJsonVar["result"]["business_name"].stringValue, forKey: OUTLET_NAME)
                    USER_DEFAULT.set(swiftyJsonVar["result"]["business_logo"].stringValue, forKey: OUTLET_IMAGE)
                    
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
    
    func WebVerifyNumber() {
        
        showProgressBar()
        
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["email"]     =   self.txt_SignupEmail.text! as AnyObject
        paramsDict["type"]     =   strType as AnyObject
        paramsDict["mobile"]     =   self.txt_SignupMobile.text! as AnyObject
        paramsDict["mobile_witth_country_code"]     =  strCCode + self.txt_SignupMobile.text! as AnyObject
        paramsDict["mobile_with_code"]     =  strCCode + self.txt_SignupMobile.text! as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.uploadImagesAndData(apiUrl: Router.verify_number.url(), params: (paramsDict as! [String : String]) , imageParam: [:], videoParam: [:], parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    strOtp = swiftyJsonVar["result"]["code"].stringValue
                    print("+" + strCCode + txt_SignupMobile.text!)
                    collectSignupData()
                    let vC = R.storyboard.main.otpVC()!
                    vC.strMobileWithCode = ("+" + strCCode + txt_SignupMobile.text!)
                    vC.strMobileNumber = txt_SignupMobile.text!
                    vC.strType = self.strType
                    vC.strCode = strCCode
                    let code = swiftyJsonVar["result"]["code"].numberValue
                    let optionalCode = swiftyJsonVar["result"]["optional_otp"].numberValue
                    print("Verification Code: \(code)")
                    USER_DEFAULT.set(code, forKey: VERIFICATION_CODE)
                    USER_DEFAULT.set(optionalCode, forKey: OPTIONAL_VERIFICATION_CODE)
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
    
    func collectSignupData() {
        paramSignupDict["email"]     =   self.txt_SignupEmail.text! as AnyObject
        paramSignupDict["first_name"]  =   self.txt_SignupFirstName.text! as AnyObject
        paramSignupDict["last_name"]  =   self.txt_SignupLastName.text! as AnyObject
        paramSignupDict["password"]  =   self.txt_SignupPassword.text! as AnyObject
        paramSignupDict["lat"]   =        kappDelegate.CURRENT_LAT as AnyObject
        paramSignupDict["lon"]  =        kappDelegate.CURRENT_LON as AnyObject
        paramSignupDict["register_id"]  =   "" as AnyObject?
        paramSignupDict["type"]     =   strType as AnyObject
        paramSignupDict["mobile"]     =   self.txt_SignupMobile.text! as AnyObject
        paramSignupDict["mobile_witth_country_code"]     =  strCCode + self.txt_SignupMobile.text! as AnyObject
        paramSignupDict["mobile_with_code"]     =  strCCode + self.txt_SignupMobile.text! as AnyObject
        paramSignupDict["about_us"]  =   "1" as AnyObject?
        paramSignupDict["ios_register_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject?
        paramSignupDict["pay_now_number"] = "" as AnyObject?
        paramSignupDict["local_bank_number"] = "" as AnyObject
        paramSignupDict["bank_name"] = "" as AnyObject
        paramSignupDict["country_name"] = self.strCountryName as AnyObject
        paramSignupDict["country_id"] = self.strCountryiD as AnyObject
        
        print(paramSignupDict)
    }
}

