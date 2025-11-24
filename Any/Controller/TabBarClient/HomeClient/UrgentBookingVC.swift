//
//  UrgentBookingVC.swift
//  Any
//
//  Created by mac on 28/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import DropDown

class urgentTableCell:UITableViewCell {
    @IBOutlet weak var lbl_StartTime: UILabel!
    @IBOutlet weak var btn_Three: UIButton!
    @IBOutlet weak var lbl_Breaks: UILabel!
    @IBOutlet weak var lbl_Lunch: UILabel!
    @IBOutlet weak var lbl_EndTime: UILabel!
    @IBOutlet weak var lbl_Rate: UILabel!
    @IBOutlet weak var lbl_jobtype: UILabel!
}

class UrgentBookingVC: UIViewController {
    
    @IBOutlet weak var table_Chat: UITableView!
    @IBOutlet weak var lbl_BookingHeadline: UILabel!
    
    var arr_List:[JSON] = []

    var strDate:String! = ""
    var strlat:String! = ""
    var strlon:String! = ""
    
    var drop = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customInfoWindow = Bundle.main.loadNibNamed("TopBar", owner: self, options: nil)?[0] as! TopBar
        customInfoWindow.frame = CGRect(x: 0, y: topbarHeight1, width: UIScreen.main.bounds.width , height: 55)
        customInfoWindow.btn_Chat.addTarget(self, action: #selector(goChat), for: .touchUpInside)
        customInfoWindow.btn_Notification.addTarget(self, action: #selector(GoNotificatio), for: .touchUpInside)
        customInfoWindow.btn_Menu.addTarget(self, action: #selector(GoMenu), for: .touchUpInside)
        customInfoWindow.attendanceVw.isHidden = true
        self.view.addSubview(customInfoWindow)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSpinningWheel), name: NSNotification.Name(rawValue: "ReloadCount"), object: nil)

        self.lbl_BookingHeadline.text = "\("Urgent Bookings For Today")"
    }
    
    @objc func GoMenu() {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "ProfileSettingVC") as! ProfileSettingVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }

    @objc func goChat() {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "ChatConversationVC") as! ChatConversationVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @objc func GoNotificatio() {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @objc func showSpinningWheel(notification: NSNotification) {
        GetNotificationCount()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        getUrgentBookingList()
        GetNotificationCount()
    }
    
    @IBAction func pluss(_ sender: Any) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "PublishJobVC") as! PublishJobVC
        objVC.isFrom = "Urgent"
        self.navigationController?.pushViewController(objVC, animated: true)
    }
}

//MARK: API
extension UrgentBookingVC {
    
    func GetNotificationCount() {
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_notification_count.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    let notificationData: [String: NSNumber] = [
                        "chatCount": swiftyJsonVar["chat_count"].numberValue,
                        "requestCount": swiftyJsonVar["request"].numberValue
                    ]
                    
                    NotificationCenter.default.post(name: NSNotification.Name("badgeCount"), object: "On Ride", userInfo: notificationData)

                    getUrgentBookingList()
                    
                }
            }
            
        },failureBlock: { (error : Error) in
            print(error)
            
        })
    }

    
    func getUrgentBookingList() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["shift_type"]  =   "Broadcast" as AnyObject

        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_my_set_shift.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_List  = swiftyJsonVar["result"].arrayValue
                    self.table_Chat.backgroundView = UIView()

                    self.table_Chat.reloadData()
                } else {
                    self.arr_List = []
                    self.table_Chat.backgroundView = UIView()
                    self.table_Chat.reloadData()
                    Utility.noDataFound("No Urgent Bookings At The Moment", tableViewOt: self.table_Chat, parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func webDeletShift(strSt:String) {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["id"]  =   strSt as AnyObject
        
        CommunicationManager.callPostService(apiUrl: Router.delete_my_shifts.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.getUrgentBookingList()
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

extension UrgentBookingVC: UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_List.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! urgentTableCell
      
        let dic = self.arr_List[indexPath.row]
        
        cell.lbl_jobtype.text = (dic["job_type"].stringValue)
        cell.lbl_Rate.text = "\(kCurrency)\(dic["shift_rate"].stringValue)/Hour"

        cell.lbl_StartTime.text = (dic["start_time"].stringValue)
        cell.lbl_EndTime.text = (dic["end_time"].stringValue)

        cell.lbl_Breaks.text = (dic["break_type"].stringValue)
        cell.lbl_Lunch.text = (dic["meals"].stringValue)

        if (dic["shift_accepted_status"].stringValue) == "Yes" {
            cell.btn_Three.isHidden = true
        } else {
            cell.btn_Three.isHidden = false
        }

        cell.btn_Three.tag = indexPath.row
        cell.btn_Three.addTarget(self, action: #selector(clcidelete), for: .touchUpInside)

        return cell
        
    }
    
    @objc func clcidelete(but:UIButton)  {
        let dic = arr_List[but.tag]
        drop.anchorView = but
        drop.dataSource =  ["Update","Delete"]
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in

            if index == 0 {
                let vC = R.storyboard.main().instantiateViewController(withIdentifier: "UpdateJobPublishVC") as! UpdateJobPublishVC
                vC.shift_iD = dic["id"].stringValue
                self.navigationController?.pushViewController(vC, animated: true)
            } else {
                webDeletShift(strSt: dic["id"].stringValue)
            }
        }
    }
}

extension UrgentBookingVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}


