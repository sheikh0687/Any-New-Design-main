//
//  RequestVC.swift
//  Any
//
//  Created by mac on 28/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Cosmos

class RequestVC: UIViewController {
    
    @IBOutlet weak var view_Pend: UIView!
    @IBOutlet weak var lbl_Count: UILabel!
    @IBOutlet weak var view_Count: UIView!
    @IBOutlet weak var btn_Pending: UIButton!
    @IBOutlet weak var btn_Current: UIButton!
    @IBOutlet weak var table_List: UITableView!
    
    var arr_AllCat:[JSON] = []
    var arr_AllCatColle:[JSON] = []
    var filtered:[JSON] = []
    var searchActive : Bool = false
    var arr_AllDriver:[JSON] = []
    var strId:String! = ""
    var strStatus = "Pending"
    var strDate = ""
    var dicCrent:JSON!
    
    //    let customer_Id:String! = USER_DEFAULT.value(forKey: CUSTOMERID) as? String
    //    let card_Id:String! = USER_DEFAULT.value(forKey: CARDID) as? String
    
    var customer_Id:String?
    var card_Id:String?
    
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
        
        
        table_List.estimatedRowHeight = 188
        table_List.rowHeight = UITableView.automaticDimension
        GetProfile()
    }
    
    @objc func GoSetting() {
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
    
    @objc func GoMenu() {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "ProfileSettingVC") as! ProfileSettingVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @objc func showSpinningWheel(notification: NSNotification) {
        GetNotificationCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        WebGetApprovedBooking()
        GetNotificationCount()
    }
    
    @IBAction func RequestCurrent(_ sender: Any) {
        btn_Pending.setTitleColor(UIColor.init(named: "BUTTON_COLOR"), for: .normal)
        btn_Current.setTitleColor(.white, for: .normal)
        view_Pend.backgroundColor = .white
        btn_Current.backgroundColor = UIColor.init(named: "BUTTON_COLOR")
        strStatus = "Accept"
        table_List.isHidden = true
        WebGetApprovedBooking()
    }
    
    @IBAction func pendingApproval(_ sender: Any) {
        btn_Current.setTitleColor(UIColor.init(named: "BUTTON_COLOR"), for: .normal)
        btn_Pending.setTitleColor(.white, for: .normal)
        btn_Current.backgroundColor = .white
        view_Pend.backgroundColor = UIColor.init(named: "BUTTON_COLOR")
        strStatus = "Pending"
        table_List.isHidden = true
        WebGetApprovedBooking()
    }
}

//MARK: API
extension RequestVC {
    
    func GetProfile() {
        //        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_profile.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let obj = swiftyJsonVar["result"]
                    self.customer_Id = obj["customer_id"].stringValue
                    self.card_Id = obj["card_id"].stringValue
                    print(self.customer_Id ?? "")
                    print(self.card_Id ?? "")
                } else {
                    print(swiftyJsonVar["result"].string ?? "Unknown error")
                }
                //                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            //            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    
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
                    WebGetApprovedBooking()
                }
            }
        },failureBlock: { (error : Error) in
            print(error)
        })
    }
    
    func WebGetApprovedBooking() {
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["status"]  =   strStatus as AnyObject
        paramsDict["date"]  =   strDate as AnyObject
        
        print(paramsDict)
        
        showProgressBar()
        
        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_set_shift_book_by_date.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                
                table_List.isHidden = false
                
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    if swiftyJsonVar["pending_shift_count"].numberValue != 0 {
                        view_Count.isHidden = false
                        lbl_Count.text = "\(swiftyJsonVar["pending_shift_count"].numberValue)"
                    } else {
                        view_Count.isHidden = true
                    }
                    self.arr_AllDriver = swiftyJsonVar["result"].arrayValue
                    print(self.arr_AllCat.count)
                    self.table_List.backgroundView = UIView()
                    self.table_List.reloadData()
                    
                } else {
                    
                    if swiftyJsonVar["pending_shift_count"].numberValue != 0 {
                        view_Count.isHidden = false
                        lbl_Count.text = "\(swiftyJsonVar["pending_shift_count"].numberValue)"
                    } else {
                        view_Count.isHidden = true
                    }
                    
                    if strStatus == "Accept" {
                        self.arr_AllDriver = []
                        self.table_List.backgroundView = UIView()
                        self.table_List.reloadData()
                        Utility.noDataFound("No Approved Bookings At The Moment", tableViewOt: self.table_List, parentViewController: self)
                    } else {
                        self.arr_AllDriver = []
                        self.table_List.backgroundView = UIView()
                        self.table_List.reloadData()
                        Utility.noDataFound("No Pending Bookings At The Moment", tableViewOt: self.table_List, parentViewController: self)
                    }
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebRejectBooking(strCard:String) {
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["cart_id"]  =   strCard as AnyObject
        paramsDict["status"]  =   "Reject" as AnyObject
        paramsDict["approver_id"]  =   "" as AnyObject
        paramsDict["approver_name"]  =   "" as AnyObject
        paramsDict["approver_type"]  =   "" as AnyObject
        print(paramsDict)
        
        showProgressBar()
        
        CommunicationManager.callPostService(apiUrl: Router.change_set_shift_status.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    self.WebGetApprovedBooking()
                    
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpRejectVC") as! PopUpRejectVC
                    objVC.str_Desc = "You have rejected this shifts\n\nThe service provider selected has been notified of your rejection"
                    objVC.str_Head = "Shift Rejected"
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
                    
                    
                } else {}
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
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
                    self.WebGetApprovedBooking()
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

extension RequestVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_AllDriver.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookingCellWorker
        
        let dic = arr_AllDriver[indexPath.row]
        
        // Safely unwrap and use image URL
        if let imgLogoUrl = dic["user_details"]["image"].string,
           let urlWithEncoding = imgLogoUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let urlLogo = URL(string: urlWithEncoding) {
            cell.img_Worker.sd_setImage(with: urlLogo, placeholderImage: UIImage(named: "Profile_Pla"), options: .continueInBackground, completed: nil)
        } else {
            cell.img_Worker.image = UIImage(named: "Profile_Pla")
        }
        
        // Set name
        let firstName = dic["user_details"]["first_name"].stringValue
        let lastName = dic["user_details"]["last_name"].stringValue
        cell.lbl_CompanyName.text = "\(firstName) \(lastName)"
        
        // Set shift time
        let shiftTime = "\(dic["set_shift_details"]["start_time"].stringValue) to \(dic["set_shift_details"]["end_time"].stringValue)"
        
        // Payment type and amount
        if dic["client_details"]["request_payment_type"].stringValue == "Monthly" {
            cell.lbl_EstimatedAmount.isHidden = true
        } else {
            cell.lbl_EstimatedAmount.isHidden = false
            cell.lbl_EstimatedAmount.text = "Estimated Amount: \(dic["user_details"]["currency_symbol"].stringValue)\(dic["shift_estimate_amount"].intValue) + \(dic["admin_commission"].stringValue)%"
        }
        
        cell.lbl_AttendanceRate.text = "\(dic["user_details"]["attandance"].stringValue)"
        cell.lbl_CompletedShift.text = "\(dic["user_details"]["completed_shift"].stringValue)"
        cell.lbl_Experience.text = dic["user_details"]["worker_experience"].stringValue
        cell.lbl_Review.text = "\(dic["user_details"]["average_rating"].stringValue) (\(dic["user_details"]["total_rating_count"].stringValue) Reviews)"
        cell.lbl_Certificate.text = "Certificate \(dic["user_details"]["certificate"].stringValue)"
        
        if Router.BASE_IMAGE_URL != dic["user_details"]["job_document"].stringValue {
            Utility.setImageWithSDWebImage(dic["user_details"]["job_document"].stringValue, cell.imgCertificate)
        } else {
            cell.imgCertificate.image = R.image.placeholder()
        }
    
        
        // Handle status
        if strStatus == "Accept" {
            cell.btn_Chat.isHidden = false
            cell.btn_Appr.isHidden = true
            cell.btn_Reject.isHidden = true
            cell.lbl_ClockIN.isHidden = false
            cell.lbl_TimeTop.isHidden = true
            cell.lbl_ShiftTime.isHidden = false
            cell.lbl_Address.isHidden = false
            
            cell.lbl_ShiftTime.text = dic["format_date"].stringValue
            cell.lbl_DayDate.text = "\(dic["user_details"]["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue)/Hour\n\(dic["set_shift_details"]["job_type"].stringValue)"
            cell.lbl_Address.text = shiftTime
            
            let clockInTime = dic["clock_in_time"].stringValue
            cell.lbl_ClockIN.text = clockInTime.isEmpty ? "Confirmed" : "Clock-In : \(clockInTime)"
        } else {
            cell.btn_Chat.isHidden = true
            cell.btn_Appr.isHidden = false
            cell.btn_Reject.isHidden = false
            cell.lbl_ClockIN.isHidden = true
            cell.lbl_TimeTop.isHidden = false
            cell.lbl_ShiftTime.isHidden = true
            cell.lbl_Address.isHidden = true
            
            cell.lbl_DayDate.text = "\(dic["user_details"]["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue)/Hour\n\(dic["set_shift_details"]["job_type"].stringValue)\n\(dic["format_date"].stringValue)"
            cell.lbl_TimeTop.text = shiftTime
        }
        
        // Button actions
        cell.btn_Chat.tag = indexPath.row
        cell.btn_Chat.addTarget(self, action: #selector(clciBook), for: .touchUpInside)
        
        cell.btn_Appr.tag = indexPath.row
        cell.btn_Appr.addTarget(self, action: #selector(clciBookApprove), for: .touchUpInside)
        
        cell.btn_Reject.tag = indexPath.row
        cell.btn_Reject.addTarget(self, action: #selector(clcidReject), for: .touchUpInside)
        
        cell.btn_SeeReview.tag = indexPath.row
        cell.btn_SeeReview.addTarget(self, action: #selector(clickReview), for: .touchUpInside)
        return cell
    }
    
    @objc func clcidReject(but: UIButton) {
        let dic = arr_AllDriver[but.tag]
        dicCrent = dic
        WebRejectBooking(strCard: dic["id"].stringValue)
    }
    
    @objc func clickReview(but: UIButton) {
        let vC = R.storyboard.main().instantiateViewController(withIdentifier: "UserRatingVC") as! UserRatingVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @objc func clciBook(but: UIButton) {
        let dic = arr_AllDriver[but.tag]
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "UserChat") as! UserChat
        objVC.receiverId = dic["user_details"]["id"].stringValue
        objVC.userName = "\(dic["user_details"]["first_name"].stringValue) \(dic["user_details"]["last_name"].stringValue)"
        objVC.strReasonID = dic["id"].stringValue
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @objc func clciBookApprove(but: UIButton) {
        let dic = arr_AllDriver[but.tag]
        let paymentType = dic["client_details"]["request_payment_type"].stringValue
                
        let presentApprovalPopUp: (String) -> Void = { navigateType in
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpSimpleVC") as! PopUpSimpleVC
            objVC.str_Head = "Shift Approved"
            objVC.str_Desc = "You have approved this shift\n\nThe service provider selected has been notified of your approval"
            objVC.str_Desc1 = ""
            objVC.is_Navigate = navigateType
            objVC.completion = {
                self.WebGetApprovedBooking()
            }
            objVC.modalPresentationStyle = .overCurrentContext
            objVC.modalTransitionStyle = .crossDissolve
            self.present(objVC, animated: false, completion: nil)
        }
        
        if paymentType == "Monthly" {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpApprovalVC") as! PopUpApprovalVC
            objVC.dicM = dic
            objVC.completion = {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    presentApprovalPopUp("Monthly")
                }
            }
            objVC.modalPresentationStyle = .overCurrentContext
            objVC.modalTransitionStyle = .crossDissolve
            self.present(objVC, animated: false, completion: nil)
        } else {
            if customer_Id == "" && card_Id == "" {
                let vc = kStoryboardMain.instantiateViewController(withIdentifier: "SaveCardVC") as! SaveCardVC
                vc.cloCardDetail = { (cardId, customerId) in
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpApprovalVC") as! PopUpApprovalVC
                    objVC.dicM = dic
                    objVC.card_Id = cardId
                    objVC.customer_Id = customerId
                    objVC.completion = {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            presentApprovalPopUp("SaveCard")
                        }
                    }
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
                }
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpApprovalVC") as! PopUpApprovalVC
                objVC.dicM = dic
                objVC.customer_Id = self.customer_Id ?? ""
                objVC.card_Id = self.card_Id ?? ""
                objVC.completion = {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        presentApprovalPopUp("CustomerAndCard")
                    }
                }
                objVC.modalPresentationStyle = .overCurrentContext
                objVC.modalTransitionStyle = .crossDissolve
                self.present(objVC, animated: false, completion: nil)
            }
        }
    }
}
