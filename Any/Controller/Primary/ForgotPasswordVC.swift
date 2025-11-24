

import UIKit
import SwiftyJSON
//import Firebase


class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var txt_Email: UITextField!
    @IBOutlet weak var btn_Login: UIButton!
    @IBOutlet weak var view_EmailNumber: UIView!
    @IBOutlet weak var btn_Cou: UIButton!
    
    var countryList = CountryList()
    var strCCode:String! = "65"
    @IBOutlet weak var text_Mobile: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //   strCCode = PhoneHelper.getCountryCode()
        //        btn_Cou.setTitle("+\(strCCode!)", for: .normal)
        //        countryList.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Forgot Password", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
        if isValidInput() {
            CheckEmailStatus()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func tapedCountrCode(_ sender: Any) {
        let navController = UINavigationController(rootViewController: countryList)
        self.present(navController, animated: true, completion: nil)
    }
    
    
    // MARK: - Validation
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        
        if (self.txt_Email.text?.isEmpty)! {
            isValid = false
            errorMessage = "Please Enter Valid Email Address"
        }
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
    
    //MARK:API
    func CheckEmailStatus() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["email"]     =   self.txt_Email.text! as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.forgot_password.url(), parameters: paramsDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"] == "1") {
                    let vC = R.storyboard.main().instantiateViewController(withIdentifier: "PasswordOtpVC") as! PasswordOtpVC
                    let otpCode = swiftyJsonVar["otp"].numberValue
                    USER_DEFAULT.set(otpCode, forKey: PASSWORD_RESET_CODE)
                    self.navigationController?.pushViewController(vC, animated: true)
                } else {
                    let message = swiftyJsonVar["result"].stringValue
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

extension ForgotPasswordVC:CountryListDelegate {
    
    func selectedCountry(country: Country) {
        strCCode = "\(country.phoneExtension)"
        btn_Cou.setTitle("\(country.countryCode) +\(strCCode!)", for: .normal)
    }
}
