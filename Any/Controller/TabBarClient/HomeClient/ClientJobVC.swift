//
//  ClientJobVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 09/10/24.
//

import UIKit
import SwiftyJSON

class ClientJobVC: UIViewController {
    
    @IBOutlet weak var manpower_TableVw: UITableView!
    @IBOutlet weak var jobReq_TableVw: UITableView!
    
    @IBOutlet weak var height_JobReqTable: NSLayoutConstraint!
    @IBOutlet weak var height_ManpowerTable: NSLayoutConstraint!
    
    @IBOutlet weak var date_CollectionVw: UICollectionView!
    @IBOutlet weak var jobsType_TableVw: UITableView!
    @IBOutlet weak var height_JobTypeTable: NSLayoutConstraint!
    
    @IBOutlet weak var btn_DailyJobOt: UIButton!
    @IBOutlet weak var btn_WeeklyJObOt: UIButton!
    
    @IBOutlet weak var DAILYJOB: UIStackView!
    @IBOutlet weak var WEEKLYJOB: UIStackView!
    
    @IBOutlet weak var lbl_WeeklyReqCount: UILabel!
    @IBOutlet weak var lbl_DailyReqCount: UILabel!
    
    @IBOutlet weak var lbl_Month: UILabel!
    
    @IBOutlet weak var lbl_CurrentDate: UILabel!
    @IBOutlet weak var lbl_CurrentDay: UILabel!
    @IBOutlet weak var lbl_JobTypeAndDescription: UILabel!
    @IBOutlet weak var upcomingShiftTableVw: UITableView!
    @IBOutlet weak var upcomingTableHeight: NSLayoutConstraint!
    
    let calendar = Calendar.current
    var arrWeekStartToEnd:[String] = []
    var arrDateStart:[Date] = []
    var arrDateEnd:[Date] = []
    var arrWeekDAys:[Date] = []
    var currentWeek:Int! = 0
    var selectedDate: Date?
    var arrWeekName:[String] = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    
    var arrayManPowerReq: [JSON] = []
    var arrayForJobTypes: [JSON] = []
    var arrayForUpcomingShift: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullDayNameAndDate()
        self.manpower_TableVw.register(UINib(nibName: "ManpowerCell", bundle: nil), forCellReuseIdentifier: "ManpowerCell")
        self.jobReq_TableVw.register(UINib(nibName: "JobRequestCell", bundle: nil), forCellReuseIdentifier: "JobRequestCell")
        self.date_CollectionVw.register(UINib(nibName: "DateCalCell", bundle: nil), forCellWithReuseIdentifier: "DateCalCell")
        self.jobsType_TableVw.register(UINib(nibName: "DateWiseCell", bundle: nil), forCellReuseIdentifier: "DateWiseCell")
        self.upcomingShiftTableVw.register(UINib(nibName: "UpcomingShiftCell", bundle: nil), forCellReuseIdentifier: "UpcomingShiftCell")
        
        DAILYJOB.isHidden = false
        WEEKLYJOB.isHidden = true
        
        let customInfoWindow = Bundle.main.loadNibNamed("TopBar", owner: self, options: nil)?[0] as! TopBar
        customInfoWindow.frame = CGRect(x: 0, y: topbarHeight1, width: UIScreen.main.bounds.width , height: 55)
        customInfoWindow.btn_Chat.addTarget(self, action: #selector(goChat), for: .touchUpInside)
        customInfoWindow.btn_Notification.addTarget(self, action: #selector(GoNotificatio), for: .touchUpInside)
        customInfoWindow.btn_Menu.addTarget(self, action: #selector(goProfile), for: .touchUpInside)
        customInfoWindow.attendanceVw.isHidden = true
        self.view.addSubview(customInfoWindow)
        
        let lastDayOfTheYear = Calendar.current.date(byAdding: .day, value: 100, to: Date())
        var currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "ccc"
        
        let dayOfWeek = dateFormatter.string(from: currentDate)
        
        print(dayOfWeek)
        
        print("Current Date : \(currentDate)")
        let components = calendar.dateComponents([.hour], from: currentDate)
        print(components)
        
        if let hours = components.hour, hours >= 0 && hours < 6 {
            currentDate = calendar.date(byAdding: .hour, value: 8, to: currentDate)!
        }
        
        while currentDate < lastDayOfTheYear! {
            
            var startDay:String! = ""
            var endDay:String! = ""
            
            if dayOfWeek == "Mon" {
                startDay = currentDate.formatted()
            } else  {
                startDay = currentDate.previous(.monday).formatted()
            }
            
            if dayOfWeek == "Sun" {
                endDay = currentDate.formatted()
            } else  {
                endDay = currentDate.next(.sunday).formatted()
            }
            
            print("startDay \(startDay ?? "")")
            print("endDay \(endDay ?? "")")
            
            arrWeekStartToEnd.append("\(startDay!),\(endDay!)")
            arrDateStart.append(Utility.getDate(strDte: startDay)!)
            arrDateEnd.append(Utility.getDate(strDte: endDay)!)
            
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSpinningWheel), name: NSNotification.Name(rawValue: "ReloadCount"), object: nil)
    }
    
    func fullDayNameAndDate()
    {
        self.lbl_CurrentDay.text = Utility.getCurrentDay()
        self.lbl_CurrentDate.text = Utility.getCurrentDateWithMonth()
    }
    
    @objc func showSpinningWheel(notification: NSNotification) {
        GetNotificationCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
        var dcuureDate = arrDateStart[0]
        
        while dcuureDate <= arrDateEnd[0] {
            arrWeekDAys.append(dcuureDate)
            dcuureDate = Calendar.current.date(byAdding: .day, value: 1, to: dcuureDate)!
        }
        date_CollectionVw.reloadData()
        getDataGetList()
        getJobRequests()
        GetNotificationCount()
        getUpcomingShifts()
    }
    
    @objc func goChat() {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "ChatConversationVC") as! ChatConversationVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @objc func GoNotificatio() {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @objc func goProfile()
    {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "ProfileSettingVC") as! ProfileSettingVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btn_JobTime(_ sender: UIButton) {
        
        if sender.tag == 0 {
            btn_DailyJobOt.backgroundColor = R.color.button_COLOR()
            btn_DailyJobOt.setTitleColor(.white, for: .normal)
            btn_WeeklyJObOt.backgroundColor = .systemGray6
            btn_WeeklyJObOt.setTitleColor(.darkGray, for: .normal)
            DAILYJOB.isHidden = false
            WEEKLYJOB.isHidden = true
            self.getJobRequests()
        } else {
            btn_WeeklyJObOt.backgroundColor = R.color.button_COLOR()
            btn_WeeklyJObOt.setTitleColor(.white, for: .normal)
            btn_DailyJobOt.backgroundColor = .systemGray6
            btn_DailyJobOt.setTitleColor(.darkGray, for: .normal)
            DAILYJOB.isHidden = true
            WEEKLYJOB.isHidden = false
            getDataGetList()
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        if currentWeek > 0 {
            
            arrWeekDAys = []
            currentWeek -= 1
            
            var dcuureDate = arrDateStart[currentWeek]
            while dcuureDate <= arrDateEnd[currentWeek] {
                arrWeekDAys.append(dcuureDate)
                dcuureDate = Calendar.current.date(byAdding: .day, value: 1, to: dcuureDate)!
            }
            date_CollectionVw.reloadData()
            getDataGetList()
        }
    }
    
    @IBAction func next(_ sender: Any) {
        arrWeekDAys = []
        currentWeek += 1
        var dcuureDate = arrDateStart[currentWeek]
        while dcuureDate <= arrDateEnd[currentWeek] {
            arrWeekDAys.append(dcuureDate)
            dcuureDate = Calendar.current.date(byAdding: .day, value: 1, to: dcuureDate)!
        }
        date_CollectionVw.reloadData()
        getDataGetList()
    }
    
}

// Api Calling
extension ClientJobVC {
    
    func GetNotificationCount() {
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_notification_count.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                                        
                    let notificationData: [String: NSNumber] = [
                        "chatCount": swiftyJsonVar["chat_count"].numberValue,
                        "requestCount": swiftyJsonVar["request"].numberValue
                    ]
                    
                    NotificationCenter.default.post(name: NSNotification.Name("badgeCount"), object: "On Ride", userInfo: notificationData)
                    
                    if swiftyJsonVar["request"].numberValue != 0 {
                        if let items = self.tabBarController?.tabBar.items as NSArray? {
                            let tabItem = items.object(at: 3) as! UITabBarItem
                            tabItem.badgeValue = "\(swiftyJsonVar["request"].numberValue)"
                        }
                    } else {
                        if let items = self.tabBarController?.tabBar.items as NSArray? {
                            let tabItem = items.object(at: 3) as! UITabBarItem
                            tabItem.badgeValue = nil
                            print("All Count")
                        }
                    }
                    getDataGetList()
                }
            }
            
        },failureBlock: { (error : Error) in
            print(error)
            
        })
    }
    
    
    func getDataGetList() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        let strDat = arrWeekStartToEnd[currentWeek]
        let arr = strDat.components(separatedBy: ",")
        print(strDat)
        paramDict["start_date"]  =  arr[0] as AnyObject
        paramDict["end_date"]  =   arr[1] as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_set_shift_book_client_side.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrayForJobTypes  = swiftyJsonVar["result"].arrayValue
                    print(self.arrayForJobTypes.count)
                    self.jobsType_TableVw.backgroundView = UIView()
                    self.jobsType_TableVw.reloadData()
                    self.height_JobTypeTable.constant = CGFloat(self.arrayForJobTypes.count * 90)
                } else {
                    self.arrayForJobTypes = []
                    self.jobsType_TableVw.backgroundView = UIView()
                    self.jobsType_TableVw.reloadData()
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func getJobRequests()
    {
        showProgressBar()
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["today_date"] = Utility.getCurrentShortDateNew() as AnyObject
        paramDict["today_day_name"] = Utility.getCurrentDay() as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_client_shift_by_date.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let resSwiftyJson = JSON(responseData)
                if (resSwiftyJson["status"].stringValue == "1") {
                    self.manpower_TableVw.isHidden = false
                    self.arrayManPowerReq = resSwiftyJson["result"]["worker_details"].arrayValue
                    self.lbl_JobTypeAndDescription.text = "\(resSwiftyJson["result"]["shift_name"].stringValue)\n\(resSwiftyJson["result"]["shift_description"].stringValue)"
                    print(self.arrayManPowerReq.count)
                    
                    if resSwiftyJson["pending_shift_count"].numberValue != 0 {
                        self.lbl_WeeklyReqCount.isHidden = false
                        self.lbl_WeeklyReqCount.clipsToBounds = true
                        self.lbl_WeeklyReqCount.cornerRadius1 = 10
                        self.lbl_WeeklyReqCount.text = "\(resSwiftyJson["pending_shift_count"].numberValue)"
                    } else {
                        self.lbl_WeeklyReqCount.isHidden = true
                    }
                    
                    if resSwiftyJson["today_pending_shift_count"].numberValue != 0 {
                        self.lbl_DailyReqCount.isHidden = false
                        self.lbl_DailyReqCount.clipsToBounds = true
                        self.lbl_DailyReqCount.cornerRadius1 = 10
                        self.lbl_DailyReqCount.text = "\(resSwiftyJson["today_pending_shift_count"].numberValue)"
                    } else {
                        self.lbl_DailyReqCount.isHidden = true
                    }
                    
                    self.manpower_TableVw.backgroundView = UIView()
                    self.manpower_TableVw.reloadData()
                    self.height_ManpowerTable.constant = CGFloat(self.arrayManPowerReq.count * 140)
                } else {
                    self.arrayManPowerReq = []
                    self.manpower_TableVw.isHidden = true
                    self.manpower_TableVw.backgroundView = UIView()
                    self.manpower_TableVw.reloadData()
                }
                self.hideProgressBar()
            }
            
        }, failureBlock: { (error: Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func getUpcomingShifts()
    {
        showProgressBar()
        var paramDict: [String : AnyObject] = [:]
        paramDict["user_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostApi(apiUrl: Router.get_shift_by_10day_count.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let resSwiftyJson = JSON(responseData)
                if (resSwiftyJson["status"].stringValue == "1") {
                    self.arrayForUpcomingShift = resSwiftyJson["result"].arrayValue
                    self.upcomingShiftTableVw.backgroundView = UIView()
                    self.upcomingTableHeight.constant = calculateTableHeight()
                    self.upcomingShiftTableVw.reloadData()
                } else {
                    self.arrayForUpcomingShift = []
                    self.upcomingShiftTableVw.backgroundView = UIView()
                    self.upcomingShiftTableVw.reloadData()
                }
                self.hideProgressBar()
            }
            
        }, failureBlock: { (error: Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func calculateTableHeight() -> CGFloat
    {
        var tableHeight = 0
        for val in self.arrayForUpcomingShift
        {
            if val["shift_details"].count > 0 {
                let rowCount = val["shift_details"].count
                let rowHeight = 60 + (rowCount * 190)
                tableHeight = tableHeight + rowHeight
            } else {
                tableHeight = tableHeight + 60
            }
        }
        return CGFloat(tableHeight)
    }
}

extension ClientJobVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == jobReq_TableVw {
            return 0
        } else if tableView == manpower_TableVw {
            return arrayManPowerReq.count
        } else if tableView == jobsType_TableVw {
            return arrayForJobTypes.count
        } else {
            return arrayForUpcomingShift.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == jobReq_TableVw {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JobRequestCell", for: indexPath) as! JobRequestCell
            return cell
        } else if tableView == manpower_TableVw {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ManpowerCell", for: indexPath) as! ManpowerCell
            let obj = self.arrayManPowerReq[indexPath.row]
            
            cell.lbl_WorkerName.text = "\(obj["first_name"].stringValue) \(obj["last_name"].stringValue)"
            cell.lbl_JobType.text = obj["shift_details"]["job_type"].stringValue
            cell.lbl_StartEndTime.text = "\(obj["shift_details"]["start_time"].stringValue) to \(obj["shift_details"]["end_time"].stringValue)"
            
            cell.lbl_HourlyRate.text = "\(obj["currency_symbol"].stringValue)\(obj["shift_booking_details"]["shift_rate"].stringValue)/Hour"
            
            if obj["shift_booking_details"]["status"].stringValue == "Pending" {
                cell.lbl_Status.text = "Pending Approval"
            } else {
                switch obj["shift_booking_details"]["working_status"].stringValue {
                case "Pending":
                    cell.lbl_Status.text = "Confirmed"
                    cell.lbl_Status.textColor = R.color.greeN()
                case "Clock-In":
                    cell.lbl_Status.text = "Clock-In : \(obj["shift_booking_details"]["clock_in_time"].stringValue)"
                    cell.lbl_Status.textColor = .black
                case "Clock-Out":
                    cell.lbl_Status.text = "Clock-Out : \(obj["shift_booking_details"]["clock_out_time"].stringValue)"
                    cell.lbl_Status.textColor = .black
                default:
                    break
                }
            }
            
            if Router.BASE_IMAGE_URL != obj["image"].stringValue {
                Utility.setImageWithSDWebImage(obj["image"].stringValue, cell.worker_Img)
            } else {
                cell.worker_Img.image = R.image.profile_c()
            }
            
            return cell
        } else if tableView == jobsType_TableVw {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateWiseCell", for: indexPath) as! DateWiseCell
            let obj = self.arrayForJobTypes[indexPath.row]
            cell.lbl_Name.text = obj["name"].stringValue
            cell.arr_DateWiseList = obj["DayWiseCount"].arrayValue
            cell.navigationController = self.navigationController
            cell.collectionDates.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingShiftCell", for: indexPath) as! UpcomingShiftCell
            let obj = self.arrayForUpcomingShift[indexPath.row]
            cell.lbl_Date.text = obj["date"].stringValue
            cell.strDate = obj["date"].stringValue
            cell.lbl_Date.cornerRadius1 = 10
            cell.navigationController = self.navigationController
            cell.arrayShift = obj["shift_details"].arrayValue
            cell.shiftTableHeight.constant = CGFloat(obj["shift_details"].count * 190)
            cell.ShiftTableVw.reloadData()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == manpower_TableVw {
            return 140
        } else if tableView == jobReq_TableVw {
            return 100
        } else if tableView == jobsType_TableVw {
            return 90
        } else {
            if self.arrayForUpcomingShift[indexPath.row]["shift_details"].count > 0 {
                let rowCount = self.arrayForUpcomingShift[indexPath.row]["shift_details"].count
                let rowHeight = 60 + (rowCount * 190)
                print(rowHeight)
                return CGFloat(rowHeight)
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == manpower_TableVw {
            let vC = R.storyboard.main().instantiateViewController(withIdentifier: "RequestVC") as! RequestVC
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }
}

extension ClientJobVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrWeekDAys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCalCell", for: indexPath) as! DateCalCell
        let strdate = arrWeekDAys[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        cell.lbl_Days.text = arrWeekName[indexPath.row]
        cell.lbl_Dates.text = formatter.string(from: strdate)
        formatter.dateFormat = "MMM yyyy"
        lbl_Month.text = formatter.string(from: strdate)
        
        let today = Calendar.current.startOfDay(for: Date()) // Get only date without time
        let cellDate = Calendar.current.startOfDay(for: strdate)
        
        if cellDate == today {
            // Highlight today's date
            cell.main_Vw.backgroundColor = .white
            cell.main_Vw.cornerRadius1 = 20
            cell.lbl_Days.textColor = .black
            cell.lbl_Dates.textColor = .black
            cell.lbl_Today.isHidden = false
        } else {
            // Default state
            cell.main_Vw.backgroundColor = UIColor.clear
            cell.lbl_Days.textColor = .white
            cell.lbl_Dates.textColor = .white
            cell.lbl_Today.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let widths = date_CollectionVw.frame.width // 414
        return CGSize(width: widths/7 - 8, height: self.date_CollectionVw.frame.height)
    }
}
