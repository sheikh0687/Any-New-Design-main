//
//  PasswordOtpVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 28/01/25.
//

import UIKit
import OTPFieldView

class PasswordOtpVC: UIViewController {

    @IBOutlet weak var otpTextFieldView: OTPFieldView!
    
    var enteredOtp:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOtpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Password Reset", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    func setupOtpView() {
        otpTextFieldView.fieldsCount = 5
        otpTextFieldView.fieldBorderWidth = 1
        otpTextFieldView.defaultBorderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        otpTextFieldView.filledBorderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        otpTextFieldView.filledBackgroundColor = .systemGray6
        otpTextFieldView.cursorColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        otpTextFieldView.displayType = .roundedCorner
        otpTextFieldView.fieldSize = 60
        otpTextFieldView.separatorSpace = 8
        otpTextFieldView.shouldAllowIntermediateEditing = false
        otpTextFieldView.initializeUI()
        otpTextFieldView.delegate = self
    }
    
    @IBAction func btn_Next(_ sender: UIButton) {
        if validateInput() {
            let vC = R.storyboard.main().instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }
}

extension PasswordOtpVC: OTPFieldViewDelegate {
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp: String) {
        self.enteredOtp = otp
        print(otp)
    }
    
    func hasEnteredAllOTP(hasEnteredAll: Bool) -> Bool {
        return false
    }
    
    func validateInput() -> Bool {
        // Retrieve the value as Int and convert to String
        let storedCode = USER_DEFAULT.value(forKey: PASSWORD_RESET_CODE) as? Int
        let storedCodeString = storedCode.map { String($0) } // Convert Int to String safely
        let trimmedEnteredOtp = enteredOtp?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("Stored Code: \(storedCodeString ?? "nil")")
        print("Entered OTP: \(trimmedEnteredOtp ?? "nil")")
        
        // Compare values
        if let storedCodeString = storedCodeString,
            let enteredOtp = trimmedEnteredOtp {
            if storedCodeString == enteredOtp {
                return true
            } else {
                self.alert(alertmessage: "Please enter the valid verification code")
                return false
            }
        } else {
            self.alert(alertmessage: "Please enter the verification!")
            return false
        }
    }
}
