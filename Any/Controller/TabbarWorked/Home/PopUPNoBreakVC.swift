//
//  PopUPNoBreakVC.swift
//  Any
//
//  Created by mac on 07/06/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import DropDown

class PopUPNoBreakVC: UIViewController {
    
    @IBOutlet weak var lbl_Desc2: UILabel!
    @IBOutlet weak var view_Approve: UIView!
    @IBOutlet weak var view_Top: UIView!
    @IBOutlet weak var lbl_Aprover: UILabel!
    @IBOutlet weak var lbl_DEsc: UILabel!
    @IBOutlet weak var lbl_Head: UILabel!
    @IBOutlet weak var btn_two: UIButton!
    
    var arr_AllApprove:[JSON]! = []
    var drop = DropDown()
    
    var strFrom:String! = ""
    var strHead:String! = ""
    var strDesc:String! = ""
    var strDesc2:String! = ""
    var strcartid:String! = ""
    var dicApp:JSON!
    var strClienID:String! = ""
    var strBreakType:String! = ""
    var strBreakTime:String! = ""
    
    var delegate: FooTwoViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Head.text = strHead
        lbl_DEsc.text = strDesc
        lbl_Desc2.text = strDesc2
        
        if strFrom == "0" {
            btn_two.setTitle("Yes, proceed", for: .normal)
            strBreakTime = "No Break Taken"
        } else if strFrom == "1" {
            lbl_DEsc.font = UIFont(name:"Avenir-Book",size:14)
            view_Top.isHidden = true
            btn_two.setTitle("Start Break", for: .normal)
            strBreakTime = "30 min"
        } else if strFrom == "2" {
            lbl_DEsc.font = UIFont(name:"Avenir-Book",size:14)
            view_Top.isHidden = true
            view_Approve.isHidden = true
            lbl_Desc2.isHidden = true
            strBreakTime = "1 hour"
            btn_two.setTitle("Yes, proceed", for: .normal)
        } else {
            btn_two.setTitle("Yes, proceed", for: .normal)
            view_Top.isHidden = true
            view_Approve.isHidden = true
        }
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
        webbrakType()
        self.dismiss(animated: false, completion: nil)
    }
    
    func GetProfile() {
        
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"]  =   strClienID as AnyObject
        paramsDict["status"]  =   "Accept" as AnyObject
        
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
            }
            
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func webbrakType() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["cart_id"]  =   strcartid as AnyObject
        
        if self.lbl_Aprover.text == "" {
            paramDict["break_approver_id"]  =   "" as AnyObject
            paramDict["break_approver_name"]  =   "" as AnyObject
        } else {
            paramDict["break_approver_id"]  =   dicApp["id"].stringValue as AnyObject
            paramDict["break_approver_name"]  =   "\(dicApp["first_name"].stringValue) \(dicApp["last_name"].stringValue)" as AnyObject
        }
        
        paramDict["break_type"]  =   strBreakType as AnyObject
        paramDict["break_time"]  =    strBreakTime as AnyObject
        
        CommunicationManager.callPostService(apiUrl: Router.add_break_time.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    delegate?.myVCDidFinish(text: strFrom)
                    self.dismiss(animated: false, completion: nil)
                    
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

