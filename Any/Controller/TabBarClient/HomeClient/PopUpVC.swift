//
//  PopUpVC.swift
//  Any
//
//  Created by mac on 31/05/23.
//

import UIKit
import SwiftyJSON

class PopUpVC: UIViewController {
    
    @IBOutlet weak var lbl_DEsc: UILabel!
    @IBOutlet weak var lbl_Head: UILabel!
    @IBOutlet weak var btn_one: UIButton!
    @IBOutlet weak var btn_two: UIButton!
    
    var completion: (() -> Void)?
    var str_One:String! = ""
    var str_Two:String! = ""
    var strFrom:String! = ""
    var strStatus:String! = ""
    
    var str_Head:String! = "Are you sure want to stop searching for part time workers?"
    var str_Desc:String! = "Accepted bookings will not be cancelled"
    var dicApp:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_Head.text = str_Head
        lbl_DEsc.text = str_Desc
        
        if strFrom == "Summery" {
            btn_one.isHidden = true
            btn_two.setTitle("Home", for: .normal)
            
        } else {
            btn_one.setTitle(str_One, for: .normal)
            btn_two.setTitle(str_Two, for: .normal)
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        if strFrom == "Summery" {
            if let completion = completion {
                completion()
            }
            self.dismiss(animated: false, completion: nil)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func one(_ sender: Any) {
        
        if strFrom == "Home" {
            getDataGetList()
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func two(_ sender: Any) {
        if strFrom == "Summery" {
            if let completion = completion {
                completion()
                
            }
            self.dismiss(animated: false, completion: nil)
            
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func getDataGetList() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["date"]  =  dicApp["week_date"].stringValue as AnyObject
        paramDict["day"]  =   dicApp["name"].stringValue as AnyObject
        paramDict["status"]  =   strStatus as AnyObject
        paramDict["job_type_id"] = dicApp["job_type_id"].stringValue as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.add_client_date_wise_open_close.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    if let completion = completion {
                        completion()
                    }
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
