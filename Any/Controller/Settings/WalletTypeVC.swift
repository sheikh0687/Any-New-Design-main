//
//  WalletTypeVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 14/10/24.
//

import UIKit
import SwiftyJSON

class WalletTypeVC: UIViewController {
    
    @IBOutlet weak var btn_CardPayment: UIButton!
    @IBOutlet weak var btn_MonthlyPayment: UIButton!
    
    var shouldShowSuccessMessage: Bool = false
    
    let paymentType = USER_DEFAULT.value(forKey: PAYMENT_TYPE) as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if paymentType == "Each Job" {
            self.btn_CardPayment.setImage(R.image.blueCirclecheck(), for: .normal)
            self.btn_MonthlyPayment.setImage(R.image.ellipse9(), for: .normal)
        } else {
            self.btn_CardPayment.setImage(R.image.ellipse9(), for: .normal)
            self.btn_MonthlyPayment.setImage(R.image.blueCirclecheck(), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Wallet Settings", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btnSelectBiilingType(_ sender: UIButton) {
        if sender.tag == 0 {
            if let selectedImage = R.image.blueCirclecheck(),
               let unselectedImage = R.image.ellipse9() {
                self.btn_CardPayment.setImage(selectedImage, for: .normal)
                self.btn_MonthlyPayment.setImage(unselectedImage, for: .normal)
            }
            USER_DEFAULT.set("Each Job", forKey: PAYMENT_TYPE)
        } else {
            if let selectedImage = R.image.blueCirclecheck(),
               let unselectedImage = R.image.ellipse9() {
                self.btn_CardPayment.setImage(unselectedImage, for: .normal)
                self.btn_MonthlyPayment.setImage(selectedImage, for: .normal)
            }
            USER_DEFAULT.set("Monthly", forKey: PAYMENT_TYPE)
        }
    }
    
    @IBAction func btn_SaveCard(_ sender: UIButton) {
        UpdatePaymentMethod()
    }
}

extension WalletTypeVC {
    
    func UpdatePaymentMethod() {
        showProgressBar()
        guard let userId = USER_DEFAULT.value(forKey: USERID),
              let paymentType = USER_DEFAULT.value(forKey: PAYMENT_TYPE) else {
            hideProgressBar()
            Utility.showAlertMessage(
                withTitle: APPNAME,
                message: "User or payment type is missing.",
                delegate: nil,
                parentViewController: self
            )
            return
        }
        
        let paramDict: [String: AnyObject] = [
            "user_id": userId as AnyObject,
            "request_payment_type": paymentType as AnyObject
        ]
        
        print("Sending Parameters: \(paramDict)")
        
        CommunicationManager.callPostService(apiUrl: Router.update_request_payment_type.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    Utility.showAlertWithAction(withTitle: APPNAME, message: "Your payment method has been successfully updated", delegate: nil, parentViewController: self) { bool in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
}
