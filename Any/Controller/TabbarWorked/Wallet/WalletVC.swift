//
//  WalletVC.swift
//  Any
//
//  Created by mac on 19/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Cosmos

class WalletVC: UIViewController {
    
    @IBOutlet weak var lbl_JobsCount: UILabel!
    @IBOutlet weak var lbl_Earning: UILabel!
    @IBOutlet weak var table_List: UITableView!
    
    var arr_AllDriver:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let customInfoWindow = Bundle.main.loadNibNamed("TopBar", owner: self, options: nil)?[0] as! TopBar
        customInfoWindow.frame = CGRect(x: 0, y: topbarHeight1, width: UIScreen.main.bounds.width , height: 55)
        customInfoWindow.btn_Chat.addTarget(self, action: #selector(goChat), for: .touchUpInside)
        customInfoWindow.btn_Notification.addTarget(self, action: #selector(GoNotificatio), for: .touchUpInside)
        customInfoWindow.menu_Vw.isHidden = true
        customInfoWindow.attendanceVw.isHidden = true
        self.view.addSubview(customInfoWindow)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSpinningWheel), name: NSNotification.Name(rawValue: "ReloadCount"), object: nil)

        table_List.estimatedRowHeight = 200
        table_List.rowHeight = UITableView.automaticDimension
    }
    
    @objc func goChat() {
        if Utility.isUserLogin() {
            let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "ChatConversationVC") as! ChatConversationVC
            self.navigationController?.pushViewController(objVC, animated: true)
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    @objc func GoNotificatio() {
        if Utility.isUserLogin() {
            let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            self.navigationController?.pushViewController(objVC, animated: true)
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }

    @objc func showSpinningWheel(notification: NSNotification) {
       Task {
           await GetNotificationCount()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Task {
            await WebGetApprovedBooking()
            await GetNotificationCount()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

//MARK: API
extension WalletVC {
    
    func GetNotificationCount() async {
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        print(paramsDict)
        
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.get_notification_count.url(), parameters: paramsDict, parentViewController: self)
            if(swiftyJsonVar["status"].stringValue == "1") {
                
                let notificationData: [String: NSNumber] = [
                    "chatCount": swiftyJsonVar["chat_count"].numberValue,
                    "requestCount": swiftyJsonVar["request"].numberValue
                ]
                
                NotificationCenter.default.post(name: NSNotification.Name("badgeCount"), object: "On Ride", userInfo: notificationData)
                
               Task {
                   await WebGetApprovedBooking()
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func WebGetApprovedBooking() async {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["worker_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
                
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.get_shift_complete_by_worker.url(), parameters: paramsDict, parentViewController: self)
            table_List.isHidden = false
            
            if(swiftyJsonVar["status"].stringValue == "1") {
                
                self.lbl_Earning.text = "\(USER_DEFAULT.value(forKey: CURRENCY_SYMBOL) ?? "") \(swiftyJsonVar["total_earning"].number ?? 0)"
                self.lbl_JobsCount.text = "\(swiftyJsonVar["total_job"].number ?? 0)"
                
                self.arr_AllDriver = swiftyJsonVar["result"].arrayValue
                self.table_List.backgroundView = UIView()
                
                self.table_List.reloadData()
            } else {
                self.lbl_Earning.text = "0"
                self.lbl_JobsCount.text = "0"
                
                self.arr_AllDriver = []
                self.table_List.backgroundView = UIView()
                self.table_List.reloadData()
                Utility.noDataFound("No Transactions At The Moment", tableViewOt: self.table_List, parentViewController: self)
                
            }
        } catch {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        }
        
        hideProgressBar()
    }
}


extension WalletVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_AllDriver.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookingCellWorker
        
        let dic = arr_AllDriver[indexPath.row]
        cell.lbl_DayDate.text = (dic["format_date"].stringValue)
        cell.lbl_CompanyName.text = "\(dic["address"].stringValue)"
        
        let shiftTime = "\(dic["total_working_hr_time"].stringValue) Hour/Rate \(dic["set_shift_details"]["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue) = \(dic["set_shift_details"]["currency_symbol"].stringValue)\(dic["total_amount"].stringValue)"
        
        let strTyp = dic["set_shift_details"]["break_type"].stringValue
        
        var strBr = ""
        
        if strTyp == "Not Aplicable" {
            strBr = "Break Type : Not Aplicable"
        } else {
            strBr = "\(strTyp) Break : \(dic["break_time"].stringValue)"
        }
        
//        if strTyp == "Not Applicable" {
//            strBr = "Break Type : Not Applicable"
//        } else {
//            strBr = "\(strTyp) Break : \(dic["break_time"].stringValue)"
//        }
        
        cell.lbl_ShiftTime.text = shiftTime
        cell.lbl_Address.text = "Time-In \(dic["clock_in_time"].stringValue) / Time-Out \(dic["clock_out_time"].stringValue)\n\n\(strBr)"
        
        return cell
        
    }
}

extension WalletVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

