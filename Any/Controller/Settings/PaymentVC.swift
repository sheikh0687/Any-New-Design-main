//
//  PaymentVC.swift
//  Shif
//
//  Created by Techimmense Software Solutions on 28/10/23.
//

import UIKit
import InputMask
import SwiftyJSON
import StripePayments


class PaymentVC: UIViewController {
    
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var txtCardHolderName: UITextField!
    @IBOutlet weak var txtCardNumber: UITextField!
    
    @IBOutlet weak var txtExpiryDate: UITextField!
    @IBOutlet weak var txtSecurityCode: UITextField!
    @IBOutlet var listnerCardNum: MaskedTextFieldDelegate!
    @IBOutlet var listerExpiryDate: MaskedTextFieldDelegate!
    @IBOutlet weak var lbl_CardPayment: UILabel!
    
    var amount = 0.0
    var planId = ""
    var requestId = ""
    var providerId = ""
    
    var customer_Id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lbl_CardPayment.text = "Upon approval of shift bookings, your card will be charged for\n*Estimated hourly rates + 15% commission fee.\nOver time charges will be processed after the shift ends.\n\nAutomatic refunds are provided for:\n*Under time\nNo-shows/Cancellations"
        
        self.configureListener()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Card Payment Information", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        if customer_Id == "" {
            getCustomerId()
        } else {
            print("Customer id already created!!")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func btnBack(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getCustomerId() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.create_Customer.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    print("Save Customer id!!")
                    self.customer_Id = swiftyJsonVar["result"]["customer_id"].stringValue
                } else {
                    let message = swiftyJsonVar["result"].string
                    print(message ?? "")
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func configureListener()
    {
        listnerCardNum.affinityCalculationStrategy = .prefix
        listnerCardNum.affineFormats = ["[0000] [0000] [0000] [0000]"]
        
        listerExpiryDate.affinityCalculationStrategy = .prefix
        listerExpiryDate.affineFormats = ["[00]/[00]"]
    }
    
    func cardValidation()
    {
        let cardParams = STPCardParams()
        
        // Split the expiration date to extract Month & Year
        if self.txtCardHolderName.text?.isEmpty == false && self.txtSecurityCode.text?.isEmpty == false && self.txtExpiryDate.text?.isEmpty == false && self.txtExpiryDate.text?.isEmpty == false {
            let expirationDate = self.txtExpiryDate.text?.components(separatedBy: "/")
            let expMonth = UInt((expirationDate?[0])!)
            let expYear = UInt((expirationDate?[1])!)
            
            // Send the card info to Strip to get the token
            cardParams.number = self.txtCardNumber.text
            cardParams.cvc = self.txtSecurityCode.text
            cardParams.expMonth = expMonth!
            cardParams.expYear = expYear!
        }
        
        let cardState = STPCardValidator.validationState(forCard: cardParams)
        switch cardState {
        case .valid:
            self.generateToken(cardParams)
        case .invalid:
            self.alert(alertmessage: "Card is invalid")
        case .incomplete:
            self.alert(alertmessage: "Card is incomplete")
        default:
            print("default")
        }
    }
    
    func generateToken(_ cardParams: STPCardParams)
    {
        STPAPIClient.shared.createToken(withCard: cardParams) { (token: STPToken?, error: Error?) in
            guard let token = token, error == nil else {
                Utility.showAlertWithAction(withTitle: "Any", message: "Something went wrong", delegate: nil, parentViewController: self, completionHandler: { (boool) in
                })
                return
            }
            print(token.tokenId)
            self.save_Cards(token.tokenId)
        }
    }
    
    func save_Cards(_ token: String) {
        
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["customer_id"]  =  customer_Id as AnyObject
        paramsDict["tok_visa"]  =  token as AnyObject
        print(paramsDict)

        
        showProgressBar()
        Api.shared.add_Card(self, paramsDict) { response in
            self.parseDataSaveCard(apiResponse: response)
        }
    }
    
    func parseDataSaveCard(apiResponse : Any) {
        DispatchQueue.main.async {
            let swiftyJsonVar = JSON(apiResponse)
            print(swiftyJsonVar)
            if(swiftyJsonVar["status"] == "1") {
                print(swiftyJsonVar["result"]["id"].stringValue)
                Utility.showAlertWithAction(withTitle: APPNAME, message: "Card saved successfully", delegate: nil, parentViewController: self, completionHandler: { (boool) in
                    self.navigationController?.popViewController(animated: true)
                })
                self.hideProgressBar()
            } else {
                Utility.showAlertWithAction(withTitle: APPNAME, message: "Something went wrong", delegate: nil, parentViewController: self, completionHandler: { (boool) in
                })
                self.hideProgressBar()
            }
        }
    }
    
    @IBAction func btnSubmit(_ sender: UIButton)
    {
        self.cardValidation()
    }
}

