//
//  UpdateJobPublishVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 18/01/25.
//

import UIKit
import SwiftyJSON

class TimeSelectionBean {
    var startTime: String = ""
    var endTime: String = ""
}

class UpdateJobPublishVC: UIViewController {
    
    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var lbl_WorkerNum: UILabel!
    @IBOutlet weak var lbl_SelectSchedule: UILabel!
    @IBOutlet weak var lbl_SelectDay: UILabel!
    @IBOutlet weak var daysText: UILabel!
    
    @IBOutlet weak var lbl_BreakType: UILabel!
    @IBOutlet weak var lbl_ProvidedMeal: UILabel!
    @IBOutlet weak var lbl_Note: UILabel!
    @IBOutlet weak var lbl_SetRate: UILabel!
    @IBOutlet weak var lbl_OutletName: UILabel!
    
    @IBOutlet weak var dateSelectionVw: UIView!
    
    @IBOutlet weak var workerShiftVw: UIView!
    @IBOutlet weak var outletView: UIView!
    @IBOutlet weak var workerShiftTableVw: UITableView!
    @IBOutlet weak var workerShiftTableHeight: NSLayoutConstraint!
    @IBOutlet weak var txt_NoteToWorker: UITextView!
    @IBOutlet weak var btn_ToAllWorkerOt: UIButton!
    
    @IBOutlet weak var shiftVw: UIView!
    
    var shift_iD:String = ""
    var arrayWorkerShiftTime:[JSON] = []
    var staticWorkerShiftTime:[JSON] = []
    var arrayDaysName:[JSON] = []
    
    var strJobTypeName:String = ""
    var strJobId:String = ""
    var workerCount:Int = 1
    
    var strStartTime:String = ""
    var strEndTime:String = ""
    var strBreak:String = ""
    var strMeal:String = ""
    var strSingleDate:String = ""
    var shiftType:String = ""
    var strBreakTime:String = ""
    var strOutletName: String = ""
    var strOutletiD: String = ""
    
    var strDaysName:String = ""
    var strShiftStatus:String = ""
    var strApplyForAllWorker:String = ""
    
    //    var arrayWorkerTime: [String] = []
    var arrayStartTime: [String] = []
    var arrayEndTime: [String] = []
    
    var fullFetchedShiftArrayFromAPI: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.workerShiftTableVw.register(UINib(nibName: "WorkerShiftTimeCell", bundle: nil), forCellReuseIdentifier: "WorkerShiftTimeCell")
        self.WebGetBookingDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Update", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_OutletName(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Outlet"
        vC.centerTitle = "Outlet Selection"
//        vC.arrayOfOutletName = arrayOfOutlet
        vC.cloAllJobTypes = { outletName, outletiD in
            self.lbl_OutletName.text = outletName
            self.strOutletName = outletName
            self.strOutletiD = outletiD
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_JobType(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Job Type"
        vC.centerTitle = "Job Selection"
        vC.cloAllJobTypes = { valJobType, valJobiD in
            self.lbl_JobType.text = valJobType
            self.strJobTypeName = valJobType
            self.strJobId = valJobiD
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_WorkerNum(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Number of Workers"
        vC.centerTitle = "Manpower"
        vC.cloAllJobTypes = { [self] valWorkerCount, blnk in
            self.lbl_WorkerNum.text = valWorkerCount
            self.workerCount = Int(valWorkerCount) ?? 0
            
            guard let workerCount = Int(valWorkerCount), workerCount > 0 else {
                print("Invalid string value or count is zero.")
                return
            }
            
            if workerCount > self.arrayWorkerShiftTime.count {
                let increaseCol = workerCount - self.arrayWorkerShiftTime.count
                for _ in 0..<increaseCol {
                    let bean = TimeSelectionBean()
                    bean.startTime = ""
                    bean.endTime = ""
                    self.arrayWorkerShiftTime.append(JSON(bean))
                }
            } else if workerCount < self.arrayWorkerShiftTime.count {
                let decreaseCol = self.arrayWorkerShiftTime.count - workerCount
                for _ in 0..<decreaseCol {
                    self.arrayWorkerShiftTime.removeLast()
                }
            }
            
            self.workerShiftVw.isHidden = (workerCount <= 1)
            self.workerShiftTableHeight.constant = CGFloat(self.arrayWorkerShiftTime.count * 85)
            self.workerShiftTableVw.reloadData()
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Schedule(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Schedule"
        vC.centerTitle = "Schedule Selection"
        vC.cloAllJobTypes = { valJobType, blnk in
            if valJobType == "Weekly" {
                self.lbl_SelectSchedule.text = valJobType
                self.lbl_SelectDay.text = "Select Days"
                self.lbl_SetRate.text = "Default Weekly Rate"
                self.daysText.text = "Days"
                self.shiftType = "Normal"
                self.lbl_Note.isHidden = true
            } else if valJobType == "Specific Date" {
                self.lbl_SelectSchedule.text = valJobType
                self.lbl_SelectDay.text = "Select Date"
                self.lbl_SetRate.text = "Default Date or Date Rate"
                self.daysText.text = "Date"
                self.shiftType = "SingleDate"
                self.lbl_Note.isHidden = true
            } else {
                self.lbl_SelectSchedule.text = "Urgent"
                self.lbl_SelectDay.text = "Today"
                self.lbl_SelectDay.textColor = .darkGray
                self.lbl_SetRate.text = "Default Urgent Rate"
                self.daysText.text = "Date"
                self.shiftType = "Broadcast"
                self.daysText.textColor = .darkGray
                self.lbl_Note.isHidden = false
            }
            self.dateSelectionVw.isHidden = false
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_SelectWeeklyDay(_ sender: Any) {
        if self.lbl_SelectSchedule.text == "Weekly" {
            let vC = R.storyboard.main.selectAllJobTypesVC()!
            vC.headline = "Days"
            vC.centerTitle = "Choose Working Days"
            vC.isFromUpdate = true
            vC.arrayOfWeekDays = self.arrayDaysName
            vC.cloAllJobTypes = { valDays, valShiftShatus in
                self.lbl_SelectDay.text = valDays
                self.strDaysName = valDays
                self.strShiftStatus = valShiftShatus
                self.lbl_Note.isHidden = true
            }
            self.navigationController?.pushViewController(vC, animated: true)
            
        } else if self.lbl_SelectSchedule.text == "Specific Date" {
            datePickerTapped(strFormat: "yyyy-MM-dd", mode: .date, type: "Date") { date in
                self.lbl_SelectDay.text = date
                self.strSingleDate = date
            }
        } else {
            print("Today!!")
        }
    }
    
    @IBAction func btn_Rates(_ sender: UIButton) {
        let vC = R.storyboard.main.setRateVC()!
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Break(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Break Type"
        vC.centerTitle = "Breaks"
        vC.cloAllJobTypes = { valBreak, blnk in
            self.lbl_BreakType.text = valBreak
            self.strBreak = valBreak
            self.strBreakTime = blnk
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Meal(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Meal Provision"
        vC.centerTitle = "Meals"
        vC.cloAllJobTypes = { valMeal, blnk in
            self.lbl_ProvidedMeal.text = valMeal
            self.strMeal = valMeal
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_ApplyToAllWorker(_ sender: UIButton) {
        if sender.isSelected {
            // Uncheck
            sender.isSelected = false
            sender.setImage(R.image.uncheck(), for: .normal)
            strApplyForAllWorker = "No"

            // Restore timeSelectionBeans based on worker count
//            if let count = Int(workerCount), count > 0 {
            if workerCount > arrayWorkerShiftTime.count {
                    let increaseCol = workerCount - arrayWorkerShiftTime.count
                    for _ in 0..<increaseCol {
                        let bean = TimeSelectionBean()
                        bean.startTime = ""
                        bean.endTime = ""
                        arrayWorkerShiftTime.append(JSON(bean))
                    }
                } else if workerCount < arrayWorkerShiftTime.count {
                    let decreaseCol = arrayWorkerShiftTime.count - workerCount
                    for _ in 0..<decreaseCol {
                        arrayWorkerShiftTime.removeLast()
                    }
                }
//            }

        } else {
            // Check
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "Checked"), for: .normal)
            strApplyForAllWorker = "Yes"

            // Clear and add only one shift time for all
            if let firstElement = fullFetchedShiftArrayFromAPI.first {
                arrayWorkerShiftTime = [firstElement]
            } else {
                arrayWorkerShiftTime = []
            }
        }

        // Update UI
        self.workerShiftVw.isHidden = (arrayWorkerShiftTime.count <= 1)
        self.workerShiftTableHeight.constant = CGFloat(arrayWorkerShiftTime.count * 85)
        self.workerShiftTableVw.reloadData()
    }
    
    @IBAction func btn_PublishJob(_ sender: UIButton) {
        if isValidInput() {
            webUpdateJobPost()
        }
    }
    
    func isValidInput() -> Bool {
        var isValid : Bool = true;
        var errorMessage : String = ""
        if strJobTypeName == "" {
            isValid = false
            errorMessage = "Please Select Job Type"
        } else if arrayStartTime.count == 0 {
            isValid = false
            errorMessage = "Please Select Start Time"
        } else if arrayEndTime.count == 0 {
            isValid = false
            errorMessage = "Please Select End Time"
        } else if strBreak == "" {
            isValid = false
            errorMessage = "Please Select Break Type"
        } else if strMeal == "" {
            isValid = false
            errorMessage = "Please Select Meal"
        } else if shiftType == "Normal" {
            if strDaysName == "" {
                isValid = false
                errorMessage = "Please Select Days"
            }
        } else if shiftType == "SingleDate" {
            if strSingleDate == "" {
                isValid = false
                errorMessage = "Please Select Date"
            }
        }
        
        if (isValid == false) {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: errorMessage, on: self)
        }
        return isValid
    }
}

// Mark Api
extension UpdateJobPublishVC {
    
    func WebGetBookingDetails() {
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["set_shift_id"]  =   shift_iD as AnyObject
        
        print(paramsDict)
        
        showProgressBar()
        
        CommunicationManager.callPostService(apiUrl: Router.get_set_shift_details.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    let resVal = swiftyJsonVar["result"]
                    
                    self.lbl_JobType.text = resVal["job_type"].stringValue
                    
                    self.lbl_WorkerNum.text = resVal["worker_count"].stringValue
                    self.lbl_ProvidedMeal.text = resVal["meals"].stringValue
                    
                    self.lbl_BreakType.text = resVal["break_type"].stringValue
                    self.txt_NoteToWorker.text = resVal["note"].stringValue
                    
                    self.strJobTypeName = resVal["job_type"].stringValue
                    self.strJobId = resVal["job_type_id"].stringValue
                    self.strBreak = resVal["break_type"].stringValue
                    self.strMeal = resVal["meals"].stringValue
                    self.shiftType = resVal["shift_type"].stringValue
                    self.strDaysName = resVal["day_name"].stringValue
                    self.strSingleDate = resVal["single_date"].stringValue
                    self.workerCount = Int(resVal["worker_count"].stringValue) ?? 0
                    self.strStartTime = resVal["start_time"].stringValue
                    self.strEndTime = resVal["end_time"].stringValue
                    self.strBreakTime = resVal["break_time"].stringValue
                    
                    self.strApplyForAllWorker = resVal["apply_time_same_for_allworkers"].stringValue
                    self.lbl_OutletName.text = self.strOutletName
                    
                    if strOutletiD != "" {
                        self.outletView.isHidden = false
                    } else {
                        self.outletView.isHidden = true
                    }
                    
                    if resVal["shift_multi_work_time"].arrayValue.count > 0 {
                        self.arrayStartTime = resVal["shift_multi_work_time"].arrayValue.map { $0["work_start_time"].stringValue
                        }
                        self.arrayEndTime = resVal["shift_multi_work_time"].arrayValue.map {
                            $0["work_end_time"].stringValue
                        }
                    } else {
                        self.arrayStartTime.append(resVal["start_time"].stringValue)
                        self.arrayEndTime.append(resVal["end_time"].stringValue)
                    }
                    
                    if resVal["shiftStatus"].stringValue == "" {
                        let daysShift = resVal["shift_brodcast_week_days"].arrayValue.map { $0["shiftStatus"].stringValue
                        }
                        self.strShiftStatus = daysShift.joined(separator: ",")
                    } else {
                        self.strShiftStatus = resVal["shiftStatus"].stringValue
                    }
                    
                    if resVal["shift_type"].stringValue == "Normal" {
                        self.lbl_SelectSchedule.text = "Weekly"
                        self.lbl_SelectDay.text = resVal["day_name"].stringValue
                        self.daysText.text = "Days"
                        self.lbl_SetRate.text = "Default Weekly Rate"
                        self.lbl_Note.isHidden = true
                    } else if resVal["shift_type"].stringValue == "SingleDate" {
                        self.lbl_SelectSchedule.text = "Specific Date"
                        self.lbl_SelectDay.text =  resVal["single_date"].stringValue
                        self.daysText.text = "Date"
                        self.lbl_SetRate.text = "Default Date or Date Rate"
                        self.lbl_Note.isHidden = true
                    } else {
                        self.lbl_SelectSchedule.text = "Today"
                        self.lbl_SelectDay.text = "Urgent"
                        self.lbl_SelectDay.textColor = .darkGray
                        self.daysText.text = "Date"
                        self.lbl_SetRate.text = "Default Urgent Rate"
                        self.daysText.textColor = .darkGray
                        self.lbl_Note.isHidden = false
                    }
                    
                    if resVal["apply_time_same_for_allworkers"].stringValue == "Yes" {
                        self.btn_ToAllWorkerOt.setImage(#imageLiteral(resourceName: "Checked"), for: .normal)
                        
                        self.fullFetchedShiftArrayFromAPI = resVal["shift_multi_work_time"].arrayValue
                        if let firstElement = self.fullFetchedShiftArrayFromAPI.first {
                            self.arrayWorkerShiftTime = [firstElement]
                        } else {
                            self.arrayWorkerShiftTime = []
                        }
                        self.workerShiftVw.isHidden = false
                        
                    } else {
                        self.btn_ToAllWorkerOt.setImage(#imageLiteral(resourceName: "RectangleUncheck"), for: .normal)
                        self.fullFetchedShiftArrayFromAPI = resVal["shift_multi_work_time"].arrayValue
                        self.arrayWorkerShiftTime = self.fullFetchedShiftArrayFromAPI
                        self.workerShiftVw.isHidden = true
                    }
                    
                    self.arrayDaysName = resVal["shift_brodcast_week_days"].arrayValue
                    print(self.arrayDaysName.count)
                    self.workerShiftTableHeight.constant = CGFloat(self.arrayWorkerShiftTime.count * 85)
                    self.workerShiftTableVw.backgroundView = UIView()
                    self.workerShiftTableVw.reloadData()
                } else {
                    self.arrayWorkerShiftTime = []
                    self.workerShiftTableVw.backgroundView = UIView()
                    self.workerShiftTableVw.reloadData()
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func webUpdateJobPost()
    {
        var paramsDict: [String : AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["id"]  =   shift_iD as AnyObject
        paramsDict["job_type"]     =  strJobTypeName  as AnyObject
        paramsDict["job_type_id"]     =  strJobId  as AnyObject
        paramsDict["worker_count"]     =  workerCount  as AnyObject
        paramsDict["start_time"]     =  strStartTime  as AnyObject
        paramsDict["end_time"]     =  strEndTime  as AnyObject
        paramsDict["day_name"]     =  strDaysName  as AnyObject
        paramsDict["shiftStatus"]     =  strShiftStatus  as AnyObject
        paramsDict["break_type"]     =  strBreak  as AnyObject
        paramsDict["shift_type"]     =  shiftType  as AnyObject
        paramsDict["meals"]     =  strMeal  as AnyObject
        paramsDict["note"]  =   self.txt_NoteToWorker.text! as AnyObject
        
        paramsDict["single_date"] = strSingleDate as AnyObject
        
        paramsDict["apply_time_same_for_allworkers"] = strApplyForAllWorker as AnyObject
        paramsDict["multi_work_start_time"] = self.arrayStartTime.joined(separator: ",") as AnyObject
        paramsDict["multi_work_end_time"] = self.arrayEndTime.joined(separator: ",") as AnyObject
        paramsDict["shift_break_time"] = self.strBreakTime as AnyObject
        paramsDict["shift_break_time_in_min"] = Utility.convertToMinutes(from: self.strBreakTime) as AnyObject
        paramsDict["outlet_id"] = strOutletiD as AnyObject
        paramsDict["business_name"] = strOutletName as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.update_my_shifts.url(), parameters: paramsDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"] == "1") {
                    GlobalConstant.showAlertWithAction(withTitle: APPNAME, message: "Your shift updated successfully", delegate: nil, parentViewController: self) { bool in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let message = swiftyJsonVar["message"].stringValue
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message, on: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}

extension UpdateJobPublishVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayWorkerShiftTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkerShiftTimeCell", for: indexPath) as! WorkerShiftTimeCell
        let obj = self.arrayWorkerShiftTime[indexPath.row]
        
        cell.lbl_WorkerCount.text = "Worker #\(String(indexPath.row + 1))"
        let startTime = obj["work_start_time"].stringValue
        let endTime = obj["work_end_time"].stringValue
        
        cell.btn_StartTimeOt.setTitle(startTime.isEmpty ? "Start Time" : startTime, for: .normal)
        cell.btn_EndTimeOt.setTitle(endTime.isEmpty ? "End Time" : endTime, for: .normal)
        
        cell.cloStartTime = { [self] in
            datePickerTapped(strFormat: "HH:mm", mode: .time, type: "Time") { strTime in
                cell.btn_StartTimeOt.setTitle(strTime, for: .normal)
                self.strStartTime = strTime
                self.arrayStartTime.append(strTime)
            }
        }
        
        cell.cloEndTime = { [self] in
            datePickerTapped(strFormat: "HH:mm", mode: .time, type: "Time") { strTime in
                cell.btn_EndTimeOt.setTitle(strTime, for: .normal)
                self.strEndTime = strTime
                self.arrayEndTime.append(strTime)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
