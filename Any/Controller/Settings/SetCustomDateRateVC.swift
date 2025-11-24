//
//  SetCustomDateRateVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 13/01/25.
//

import UIKit
import SwiftyJSON

class SetCustomDateRateVC: UIViewController {

    @IBOutlet weak var lbl_Hour: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    var rate:Int! = 12
    var strSelectedDate:String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Set Custom Date Rate", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        self.lbl_Hour.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)12/hour"
    }
    
    @IBAction func btn_SelectDate(_ sender: UIButton) {
        datePickerTapped(strFormat: "yyyy-MM-dd", mode: .date, type: "Date") { date in
            sender.setTitle(date, for: .normal)
            self.strSelectedDate = date
        }
    }
    
    @IBAction func btn_Plus(_ sender: UIButton) {
        rate += 1
        self.lbl_Hour.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.rate!)/hour"
    }
    
    @IBAction func btn_Minus(_ sender: UIButton) {
        if rate > 12 {
            rate -= 1
            lbl_Hour.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.rate!)/hour"
        } else {
            self.alert(alertmessage: "Minimum hourly rate can't be below \(kappDelegate.dic_Profile["currency_symbol"].stringValue)12/hr")
        }
    }
    
    @IBAction func btn_Return(_ sender: UIButton) {
      self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_SetRate(_ sender: UIButton) {
        if strSelectedDate != "" {
            WebAddShift()
        } else {
            self.alert(alertmessage: "Please select the date")
        }
    }
}

extension SetCustomDateRateVC {
    
    func WebAddShift() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["day_name"]     =  "" as AnyObject
        paramsDict["date"]     =  strSelectedDate  as AnyObject
        paramsDict["rate"]     = rate as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.add_client_date_rate.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let message = swiftyJsonVar["message"].string
                    print(message ?? "")
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}

