//
//  PopUpApprovalVC.swift
//  Any
//
//  Created by mac on 31/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import DropDown

class PopUpApprovalVC: UIViewController {
    
    @IBOutlet weak var lbl_Aprover: UILabel!
    @IBOutlet weak var lbl_DEsc: UILabel!
    @IBOutlet weak var lbl_Head: UILabel!
    @IBOutlet weak var btn_two: UIButton!
   
    var completion: (() -> Void)?
    var arr_AllApprove:[JSON]! = []
    var drop = DropDown()
    var dicM:JSON!
    var dicApp:JSON!
    
    var is_Navigate:String! = ""
    var card_Id = ""
    var customer_Id = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Aprover.text = ""

    }
    override func viewWillAppear(_ animated: Bool) {
        GetProfile()
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func approver(_ sender: UIButton) {
        
        drop.anchorView = sender
        drop.dataSource =  arr_AllApprove.map({$0["first_name"].stringValue + " " + $0["last_name"].stringValue + " (" + $0["type"].stringValue + ")"})
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
         
            lbl_Aprover.text = item
            dicApp = arr_AllApprove[index]
            
        }

    }
    
    @IBAction func two(_ sender: Any) {
        webDeletShift()
    }
    func GetProfile() {

        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["status"]  =   "Accept" as AnyObject
        showProgressBar()

        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_OutletAdmin_AuthrisedApprover.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllApprove = swiftyJsonVar["result"].arrayValue
                    self.dicApp = self.arr_AllApprove[0]
                    self.lbl_Aprover.text = "\(dicApp["first_name"].stringValue)  \(dicApp["last_name"].stringValue) (\(dicApp["type"].stringValue))"
                } else {
                    self.lbl_Aprover.text = ""
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }

    func webDeletShift() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["cart_id"]  =   dicM["id"].stringValue as AnyObject
        paramDict["status"]  =   "Accept" as AnyObject
        
        if self.lbl_Aprover.text == "" {
            paramDict["approver_id"]  =   "" as AnyObject
            paramDict["approver_name"]  =   "" as AnyObject
            paramDict["approver_type"]  =   "" as AnyObject
        } else {
            paramDict["approver_id"]  =   dicApp["id"].string as AnyObject
            paramDict["approver_name"]  =   "\(dicApp["first_name"].string ?? "") \(dicApp["last_name"].string  ?? "")" as AnyObject
            paramDict["approver_type"]  =   dicApp["type"].string as AnyObject
        }
        paramDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["card_id"] = card_Id as AnyObject
        paramDict["customer_id"] = customer_Id as AnyObject
        
        CommunicationManager.callPostService(apiUrl: Router.change_set_shift_status.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    if let completion = completion {
                      completion()
                    }
                    if self.is_Navigate == "Monthly" || self.is_Navigate == "CustomerAndCard" {
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        self.dismiss(animated: false, completion: nil)
                    }
                } else {
                    Utility.showAlertMessage(withTitle: EMPTY_STRING, message: swiftyJsonVar["message"].stringValue, delegate: nil,parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
}
