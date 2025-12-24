

import UIKit
import SwiftyJSON
import SDWebImage
import Cosmos

class BookingCellWorker:UITableViewCell {
    
    @IBOutlet weak var img_Worker: UIImageView!
    @IBOutlet weak var lbl_TimeTop: UILabel!
    @IBOutlet weak var btn_Reject: UIButton!
    @IBOutlet weak var btn_Appr: UIButton!
    @IBOutlet weak var btn_Delet: UIButton!
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var lbl_ShiftTime: UILabel!
    @IBOutlet weak var btn_Chat: UIButton!
    @IBOutlet weak var lbl_DayDate: UILabel!
    @IBOutlet weak var lbl_CompanyName: UILabel!
    @IBOutlet weak var lbl_ClockIN: UILabel!
    @IBOutlet weak var lbl_EstimatedAmount: UILabel!
    @IBOutlet weak var lbl_JobTYpe: UILabel!
    
    @IBOutlet weak var lbl_AttendanceRate: UILabel!
    @IBOutlet weak var lbl_CompletedShift: UILabel!
    @IBOutlet weak var lbl_Experience: UILabel!
    @IBOutlet weak var lbl_Review: UILabel!
    @IBOutlet weak var lbl_Certificate: UILabel!
    @IBOutlet weak var btn_SeeReview: UIButton!
    
    @IBOutlet weak var btn_GiveRating: UIButton!
    @IBOutlet weak var view_GiveRating: UIView!
    @IBOutlet weak var reviewView: UIStackView!
    @IBOutlet weak var cosmosVw: CosmosView!
    @IBOutlet weak var lbl_Feedback: UILabel!
    
    @IBOutlet weak var imgCertificate: UIImageView!
}

class serviceCell: UICollectionViewCell {
    
    @IBOutlet weak var ratingvv: CosmosView!
    @IBOutlet weak var lbl_CatName: UILabel!
    @IBOutlet weak var img_Cat: UIImageView!
}

class HomeVC: UIViewController {
    
    @IBOutlet weak var lbl_Urgent: UILabel!
    @IBOutlet weak var view_Urgent: UIView!
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
    var strStatus = "Accept"
    var strAttendance:String = ""
    var strReview: String = ""
    var strRatingCount:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print(Utility.getCurrentTime24HOur())
        GetProfile()
        
        let customInfoWindow = Bundle.main.loadNibNamed("TopBar", owner: self, options: nil)?[0] as! TopBar
        customInfoWindow.frame = CGRect(x: 0, y: topbarHeight1, width: UIScreen.main.bounds.width , height: 55)
        customInfoWindow.btn_Chat.addTarget(self, action: #selector(goChat), for: .touchUpInside)
        customInfoWindow.btn_Notification.addTarget(self, action: #selector(GoNotificatio), for: .touchUpInside)
        customInfoWindow.btn_SeeAll.addTarget(self, action: #selector(GoReview), for: .touchUpInside)
        
        customInfoWindow.lbl_AttendanceRate.text = self.strAttendance
        customInfoWindow.lbl_Review.text = "\(self.strReview) ( \(self.strRatingCount) Reviews )"
        customInfoWindow.menu_Vw.isHidden = true
        customInfoWindow.attendanceVw.isHidden = false
        self.view.addSubview(customInfoWindow)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSpinningWheel), name: NSNotification.Name(rawValue: "ReloadCount"), object: nil)
        
        self.table_List.register(UINib(nibName: "BookingCell", bundle: nil), forCellReuseIdentifier: "BookingCell")
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
    
    @objc func GoReview() {
        if Utility.isUserLogin() {
            let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "UserRatingVC") as! UserRatingVC
            self.navigationController?.pushViewController(objVC, animated: true)
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    @objc func showSpinningWheel(notification: NSNotification) {
        GetNotificationCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        if Utility.isUserLogin() {
            WebGetApprovedBooking()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Utility.isUserLogin() {
            GetNotificationCount()
        }
    }
    
    @IBAction func RequestCurrent(_ sender: Any) {
        btn_Pending.setTitleColor(.darkGray, for: .normal)
        btn_Current.setTitleColor(.white, for: .normal)
        view_Pend.backgroundColor = .systemGray6
        btn_Current.backgroundColor = UIColor.init(named: "BUTTON_COLOR")
        strStatus = "Accept"
        table_List.isHidden = true
        if Utility.isUserLogin() {
            WebGetApprovedBooking()
        }
    }
    
    @IBAction func pendingApproval(_ sender: Any) {
        btn_Current.setTitleColor(.darkGray, for: .normal)
        btn_Pending.setTitleColor(.white, for: .normal)
        btn_Current.backgroundColor = .systemGray6
        view_Pend.backgroundColor = UIColor.init(named: "BUTTON_COLOR")
        strStatus = "Pending"
        table_List.isHidden = true
        if Utility.isUserLogin() {
            WebGetApprovedBooking()
        }
    }
    
    @IBAction func seeSameDayRequest(_ sender: Any) {
        if Utility.isUserLogin() {
            let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "SameDayRequestVC") as! SameDayRequestVC
            self.navigationController?.pushViewController(objVC, animated: true)
        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
    
    func Logout() {
        let alertController = UIAlertController(title: APP_NAME, message: "Your session expire login again?", preferredStyle: .alert)
        let yesAction: UIAlertAction = UIAlertAction(title: "Ok", style: .default) { action -> Void in
            UserDefaults.standard.removeObject(forKey: STATUS)
            UserDefaults.standard.synchronize()
            Switcher.updateRootVC()
        }
        
        alertController.addAction(yesAction)
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: API
extension HomeVC {
    
    func GetNotificationCount() {
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_notification_count.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    //                    let notificationData: [String: NSNumber] = [
                    //                        "chatCount": swiftyJsonVar["chat_count"].numberValue,
                    //                        "requestCount": swiftyJsonVar["request"].numberValue
                    //                    ]
                    //                    
                    //                    NotificationCenter.default.post(name: NSNotification.Name("badgeCount"), object: "On Ride", userInfo: notificationData)
                    
                    let notificationData: [String: Any] = [
                        "chatCount": swiftyJsonVar["chat_count"].numberValue,
                        "requestCount": swiftyJsonVar["request"].numberValue,
                        "attendanceRate": swiftyJsonVar["attandance"].stringValue,
                        "review": swiftyJsonVar["average_rating"].stringValue,
                        "ratingCount": swiftyJsonVar["total_rating_count"].numberValue
                    ]
                    
                    NotificationCenter.default.post(
                        name: NSNotification.Name("badgeCount"),
                        object: "On Ride",
                        userInfo: notificationData
                    )
                    
                    if swiftyJsonVar["broadcast_booking"].numberValue != 0 {
                        lbl_Urgent.text = "\(swiftyJsonVar["broadcast_booking"].numberValue)"
                        view_Urgent.isHidden = false
                    } else {
                        lbl_Urgent.text = "0"
                        view_Urgent.isHidden = true
                    }
                    
                    WebGetApprovedBooking()
                    
                }
            }
            
        },failureBlock: { (error : Error) in
            print(error)
            
        })
    }
    
    func WebGetApprovedBooking() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["status"]  =   strStatus as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_set_shift_book.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
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
    
    func webDeletShift(strSt:String,dics:JSON) {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["cart_id"]  =   strSt as AnyObject
        paramDict["status"]  =   "Cancel" as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.change_set_shift_status_worker_side.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.WebGetApprovedBooking()
                    
                    let shiftTime = "\(dics["set_shift_details"]["start_time"].stringValue) to \(dics["set_shift_details"]["end_time"].stringValue)"
                    
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpRejectVC") as! PopUpRejectVC
                    objVC.str_Desc = "\(dics["client_details"]["business_name"].stringValue),  \(dics["address"].stringValue)\n\(dics["day_name"].stringValue), \(shiftTime)"
                    objVC.str_Head = "Your shift has been successfully cancelled in:"
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
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
    
    func GetProfile() {
        
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["device_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject
        
        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_profile.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let dic = swiftyJsonVar["result"]
                    kappDelegate.dicProdile = dic
                    if dic["login_check"].stringValue == "No" {
                        Logout()
                    }
                }
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}

extension HomeVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_AllDriver.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookingCell", for: indexPath) as! BookingCell
        
        let dic = arr_AllDriver[indexPath.row]
        
        cell.lbl_BusinessName.text = "\(dic["client_details"]["business_name"].stringValue)"
        cell.lbl_DayAndDate.text = "\(dic["format_date"].stringValue)"
        
        cell.lbl_HourRate.text = "Rate: \(dic["set_shift_details"]["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue)/Hour"
        cell.lbl_ShiftTime.text = "Shift: \(dic["set_shift_details"]["start_time"].stringValue) to \(dic["set_shift_details"]["end_time"].stringValue)"
        
        cell.lbl_Address.text = "Address: \(dic["address"].stringValue)"
        
        if Router.BASE_IMAGE_URL != dic["client_details"]["business_logo"].stringValue {
            Utility.setImageWithSDWebImage(dic["client_details"]["business_logo"].stringValue, cell.logo_Img)
        } else {
            cell.logo_Img.image = R.image.placeholder_2()
        }
        
        if strStatus == "Accept" {
            cell.cloMessage = {
                let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "UserChat") as! UserChat
                objVC.receiverId = dic["client_details"]["id"].stringValue
                objVC.userName = (dic["client_details"]["first_name"].stringValue) + " " + (dic["client_details"]["last_name"].stringValue)
                objVC.strReasonID = dic["id"].stringValue
                self.navigationController?.pushViewController(objVC, animated: true)
            }
            if "\(dic["working_status"].stringValue)" == "Pending" {
                cell.btn_ConfirmOt.setTitle("Clock-in", for: .normal)
                cell.btn_ConfirmOt.setTitleColor(R.color.greeN(), for: .normal)
                cell.btn_ConfirmOt.borderColor = R.color.greeN()
            } else {
                cell.btn_ConfirmOt.setTitle("Clock-In : \(dic["clock_in_time"].stringValue)", for: .normal)
                cell.btn_ConfirmOt.setTitleColor(R.color.greeN(), for: .normal)
                cell.btn_ConfirmOt.borderColor = R.color.greeN()
            }
            cell.btn_Delete.isHidden = true
            cell.btn_SendMessageOt.isHidden = false
            
            cell.cloConfirm = { [] in
                let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "BookingDetailVC") as! BookingDetailVC
                objVC.strCartId = dic["id"].stringValue
                self.navigationController?.pushViewController(objVC, animated: true)
            }
            
        } else {
            cell.btn_Delete.isHidden = false
            cell.btn_SendMessageOt.isHidden = true
            
            cell.btn_ConfirmOt.setTitle("Pending", for: .normal)
            cell.btn_ConfirmOt.setTitleColor(R.color.button_COLOR(), for: .normal)
            cell.btn_ConfirmOt.borderColor = R.color.button_COLOR()
            
            cell.cloDelete = {
                let vC = R.storyboard.main.popUpBeforeBooking()!
                let objClient = dic["client_details"].dictionaryValue
                vC.strBookinName = "\(objClient["business_name"]?.stringValue ?? ""),\n\(objClient["business_address"]?.stringValue ?? "")\n\(dic["day_name"].stringValue) \(dic["start_time"].stringValue) \(dic["end_time"].stringValue)"
                vC.isFrom = "Withdraw"
                
                vC.cloBook = { [self] in
                    self.webDeletShift(strSt: dic["id"].stringValue, dics: dic)
                    self.dismiss(animated: true)
                }
                
                vC.modalTransitionStyle = .crossDissolve
                vC.modalPresentationStyle = .overFullScreen
                self.present(vC, animated: true)
            }
        }
        return cell
    }
}

extension HomeVC : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if strStatus == "Accept" {
            let dic = arr_AllDriver[indexPath.row]
            let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "BookingDetailVC") as! BookingDetailVC
            objVC.strCartId = dic["id"].stringValue
            self.navigationController?.pushViewController(objVC, animated: true)
        }
    }
}

