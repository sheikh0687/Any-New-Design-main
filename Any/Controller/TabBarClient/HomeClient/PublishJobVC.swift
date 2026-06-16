//
//  PublishJobVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 10/10/24.
//

import UIKit
import SwiftyJSON

class PublishJobVC: UIViewController {
    
    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var lbl_WorkerNum: UILabel!
    @IBOutlet weak var lbl_SelectSchedule: UILabel!
    @IBOutlet weak var lbl_BreakType: UILabel!
    @IBOutlet weak var lbl_ProvidedMeal: UILabel!
    @IBOutlet weak var lbl_SelectDay: UILabel!
    @IBOutlet weak var lbl_Note: UILabel!
    @IBOutlet weak var lbl_DefaultRate: UILabel!
    @IBOutlet weak var lbl_OutletName: UILabel!
    
    @IBOutlet weak var workerShiftVw: UIView!
    @IBOutlet weak var outletView: UIView!
    @IBOutlet weak var worker_TableVw: UITableView!
    @IBOutlet weak var worker_TableHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionDate: UICollectionView!
    @IBOutlet weak var timeSlot_HeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dateSelectionVw: UIView!
    @IBOutlet weak var txt_WorkerNote: UITextView!
    @IBOutlet weak var btn_ToAllWorkerOt: UIButton!
    
    var strJobTypeName: String = ""
    var strJobId: String = ""
    var workerCount: Int = 1
    
    var strStartTime: String! = ""
    var strEndTime: String! = ""
    var strBreak: String = ""
    var strSchedule: String = ""
    var strMeal: String = ""
    var shiftType: String = ""
    var strBreakTime: String = ""
    
    var strDaysName: String = ""
    var strShiftStatus: String = ""
    var strApplyForAllWorker: String = "No"
    var strOutletName: String = ""
    var strOutletiD: String = ""
    
    var arrayWorkerTime: [JSON] = []
    var fullFetchedShiftArrayFromAPI: [JSON] = []
    
    var arrayWorkerStartTime: [String] = []
    var arrayWorkerEndTime: [String] = []
    var arraySingleDate: [String] = []
    var arrayOfDays: [String] = []
    
    var isFrom: String = ""
    var isOutletSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.worker_TableVw.register(UINib(nibName: "WorkerShiftTimeCell", bundle: nil), forCellReuseIdentifier: "WorkerShiftTimeCell")
        self.collectionDate.register(UINib(nibName: "MultiDateCell", bundle: nil), forCellWithReuseIdentifier: "MultiDateCell")
        self.arrayWorkerTime.append(JSON(["work_start_time": "", "work_end_time": ""]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFrom == "Urgent" {
            self.tabBarController?.tabBar.isHidden = true
            setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Add Urgent Job", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
            self.lbl_SelectSchedule.text = "Urgent"
            self.lbl_SelectDay.text = "Today"
            self.lbl_DefaultRate.text = "Default urgent rate"
            self.lbl_SelectDay.textColor = .darkGray
            self.lbl_Note.isHidden = false
            self.shiftType = "Broadcast"
            self.strSchedule = "Fill"
            self.strDaysName = Utility.getCurrentDay()
        } else {
            self.tabBarController?.tabBar.isHidden = false
            setNavigationBarItem(LeftTitle: "", LeftImage: "", CenterTitle: "Add A New Job", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        }
        self.navigationController?.navigationBar.isHidden = false
        Task {
            await WebGetOutlet()
        }
        
        if !isOutletSelected {
            self.lbl_OutletName.text = USER_DEFAULT.value(forKey: OUTLET_NAME) as? String ?? ""
            self.strOutletiD = USER_DEFAULT.value(forKey: CLIENTID) as? String ?? ""
            self.strOutletName = USER_DEFAULT.value(forKey: OUTLET_NAME) as? String ?? ""
        } else {
            print("Outlet is selected!")
            self.isOutletSelected = false
        }
    }
    
    @IBAction func btn_OutletName(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Outlet"
        vC.centerTitle = "Outlet Selection"
        vC.cloAllJobTypes = { outletName, outletiD in
            self.lbl_OutletName.text = outletName
            self.strOutletName = outletName
            self.strOutletiD = outletiD
            self.isOutletSelected = true
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_JobType(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Job Type"
        vC.centerTitle = "Job Selection"
        vC.cloAllJobTypes = { valJobType, jobiD in
            self.lbl_JobType.text = valJobType
            self.strJobTypeName = valJobType
            self.strJobId = jobiD
            Task {
                await self.WebShiftDetailByJobType(jobiD: jobiD)
            }
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_WorkerNum(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Number of Workers"
        vC.centerTitle = "Manpower"
        vC.cloAllJobTypes = { valWorkerCount, valBlank in
            guard let newCount = Int(valWorkerCount), newCount > 0 else { return }
            
            self.lbl_WorkerNum.text = valWorkerCount
            self.workerCount = newCount
            
            let defaultEntry: JSON = {
                if let first = self.arrayWorkerTime.first {
                    return JSON(["work_start_time": first["work_start_time"].stringValue,
                                 "work_end_time":   first["work_end_time"].stringValue])
                }
                return JSON(["work_start_time": "", "work_end_time": ""])
            }()
            
            if newCount > self.arrayWorkerTime.count {
                let gap = newCount - self.arrayWorkerTime.count
                for _ in 0..<gap {
                    self.arrayWorkerTime.append(defaultEntry)
                }
            } else if newCount < self.arrayWorkerTime.count {
                self.arrayWorkerTime = Array(self.arrayWorkerTime.prefix(newCount))
            }
            
            self.workerShiftVw.isHidden = (newCount <= 1)
            self.worker_TableHeight.constant = CGFloat(self.arrayWorkerTime.count * 85)
            self.worker_TableVw.reloadData()
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Schedule(_ sender: UIButton) {
        if isFrom != "Urgent" {
            let vC = R.storyboard.main.selectAllJobTypesVC()!
            vC.headline = "Schedule"
            vC.centerTitle = "Schedule Selection"
            vC.cloAllJobTypes = { valJobType, valBlank in
                self.strSchedule = "Fill"
                if valJobType == "Weekly" {
                    self.lbl_SelectSchedule.text = valJobType
                    self.lbl_SelectDay.text = "Select Days"
                    self.lbl_DefaultRate.text = "Default Weekly Rate"
                    self.lbl_Note.isHidden = true
                    self.shiftType = "Normal"
                    // Reset SingleDate state
                    self.arraySingleDate = []
                    self.arrayOfDays = []
                    self.collectionDate.isHidden = true
                    self.timeSlot_HeightConstraint.constant = 0
                } else if valJobType == "Specific Date" {
                    self.lbl_SelectSchedule.text = valJobType
                    self.lbl_SelectDay.text = "Select Date"
                    self.lbl_DefaultRate.text = "Default Date Or Date Rate"
                    self.lbl_Note.isHidden = true
                    self.shiftType = "SingleDate"
                    // Reset Weekly state
                    self.strDaysName = ""
                } else {
                    self.lbl_SelectSchedule.text = "Urgent"
                    self.lbl_SelectDay.text = "Today"
                    self.lbl_DefaultRate.text = "Default Urgent Rate"
                    self.lbl_SelectDay.textColor = .darkGray
                    self.lbl_Note.isHidden = false
                    self.shiftType = "Broadcast"
                    self.strDaysName = Utility.getCurrentDay()
                    // Reset SingleDate state
                    self.arraySingleDate = []
                    self.arrayOfDays = []
                    self.collectionDate.isHidden = true
                    self.timeSlot_HeightConstraint.constant = 0
                }
                self.dateSelectionVw.isHidden = false
            }
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }
    
    @IBAction func btn_SelectWeeklyDay(_ sender: Any) {
        if self.lbl_SelectSchedule.text == "Weekly" {
            let vC = R.storyboard.main.selectAllJobTypesVC()!
            vC.headline = "Days"
            vC.centerTitle = "Choose Working Days"
            vC.isFromUpdate = false
            vC.cloAllJobTypes = { valDays, valShiftStatus in
                self.lbl_SelectDay.text = valDays
                self.strDaysName = valDays
                self.strShiftStatus = valShiftStatus
                self.lbl_Note.isHidden = true
            }
            self.navigationController?.pushViewController(vC, animated: true)
            
        } else if self.lbl_SelectSchedule.text == "Specific Date" {
            let vC = R.storyboard.main.calenderPickervC()!
            vC.modalTransitionStyle = .crossDissolve
            vC.modalPresentationStyle = .overFullScreen
            vC.cloOk = { [weak self] selectedDate in
                guard let self else { return }
                self.collectionDate.isHidden = false
                self.arraySingleDate.append(selectedDate)
                print(selectedDate)
                if let dayName = Utility.getDayNameAccordingToDate(from: selectedDate) {
                    self.arrayOfDays.append(dayName)
                    self.strDaysName = arrayOfDays.joined(separator: ",")
                    print(self.strDaysName)
                }
                let numberOfItemsInRow = 2 // You can adjust this based on your layout
                let numberOfRows = (arraySingleDate.count + numberOfItemsInRow - 1) / numberOfItemsInRow
                let cellHeight: CGFloat = 50
                self.timeSlot_HeightConstraint.constant = CGFloat(numberOfRows) * cellHeight
                print(self.timeSlot_HeightConstraint.constant)
                self.collectionDate.reloadData()
            }
            self.present(vC, animated: true)
        }
    }
    
    @IBAction func btn_Rates(_ sender: UIButton) {
        let vC = R.storyboard.main.setRateVC()!
        vC.strJobTypeName = self.strJobTypeName
        vC.strJobId = self.strJobId
        vC.isComingFrom = "PublishJob"
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Break(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Break Type"
        vC.centerTitle = "Breaks"
        vC.cloAllJobTypes = { valBreak, valBlank in
            self.lbl_BreakType.text = valBreak
            self.strBreak = valBreak
            self.strBreakTime = valBlank
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Meal(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Meal Provision"
        vC.centerTitle = "Meals"
        vC.cloAllJobTypes = { valMeal, valBlank in
            self.lbl_ProvidedMeal.text = valMeal
            self.strMeal = valMeal
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_ApplyToAllWorker(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            sender.setImage(R.image.uncheck(), for: .normal)
            strApplyForAllWorker = "No"
            
            if fullFetchedShiftArrayFromAPI.count == workerCount {
                arrayWorkerTime = fullFetchedShiftArrayFromAPI
            } else {
                let obj: JSON = ["work_start_time": strStartTime ?? "",
                                 "work_end_time":   strEndTime   ?? ""]
                arrayWorkerTime = Array(repeating: obj, count: workerCount)
            }
            workerShiftVw.isHidden = (workerCount <= 1)
        } else {
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "Checked"), for: .normal)
            strApplyForAllWorker = "Yes"
            
            let obj: JSON = ["work_start_time": strStartTime ?? "",
                             "work_end_time":   strEndTime   ?? ""]
            arrayWorkerTime = [obj]
            workerShiftVw.isHidden = false
        }
        
        worker_TableHeight.constant = CGFloat(arrayWorkerTime.count * 85)
        worker_TableVw.reloadData()
    }
    
    @IBAction func btn_PublishJob(_ sender: UIButton) {
        if isValidInput() {
            let vC = R.storyboard.main.confirmJobPostVC()!
            vC.strJobiD = strJobId
            collectParamJobPost()
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }
    
    func isValidInput() -> Bool {
        var errorMessage: String?
        
        if strJobTypeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Job Type"
            
        } else if shiftType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select The Schedule"
            
        } else if strBreak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Break Type"
            
        } else if strMeal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Meal"
            
        } else if shiftType == "Normal" && strDaysName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Days"
            
        } else if shiftType == "SingleDate" && arraySingleDate.isEmpty {
            errorMessage = "Please Select Date"
            
        } else if strApplyForAllWorker == "No" {
            for i in 0..<workerCount {
                if i < arrayWorkerTime.count {
                    let obj = arrayWorkerTime[i]
                    let start = obj["work_start_time"].string ?? obj["startTime"].string ?? ""
                    let end   = obj["work_end_time"].string   ?? obj["endTime"].string   ?? ""
                    if start.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                       end.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        errorMessage = "Please Select Time for Worker #\(i + 1)"
                        break
                    }
                } else {
                    errorMessage = "Please Select Time for Worker #\(i + 1)"
                    break
                }
            }
            
        } else if (strStartTime ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Start Time"
            
        } else if (strEndTime ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select End Time"
        }
        
        if let message = errorMessage {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME,
                                            andMessage: message, on: self)
            return false
        }
        return true
    }
}

// MARK: API CALLING
extension PublishJobVC {
    
    func WebGetOutlet() async {
        showProgressBar()
        var paramsDict: [String: AnyObject] = [:]
        paramsDict["client_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(
                apiUrl: Router.get_Outlet.url(),
                parameters: paramsDict,
                parentViewController: self
            )
            self.outletView.isHidden = swiftyJsonVar["status"].stringValue != "1"
        } catch {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME,
                                            andMessage: error.localizedDescription, on: self)
        }
        self.hideProgressBar()
    }
    
    func WebShiftDetailByJobType(jobiD: String) async {
        showProgressBar()
        var paramsDict: [String: AnyObject] = [:]
        paramsDict["user_id"]      = USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["job_type_id"]  = jobiD as AnyObject
        
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync (
                apiUrl: Router.get_set_shift_details_by_job_type.url(),
                parameters: paramsDict,
                parentViewController: self
            )
            
            if swiftyJsonVar["status"].stringValue == "1" {
                let resVal = swiftyJsonVar["result"]
                
                // MARK: — Labels
                self.lbl_JobType.text      = resVal["job_type"].stringValue
                self.lbl_WorkerNum.text    = resVal["worker_count"].stringValue
                self.lbl_ProvidedMeal.text = resVal["meals"].stringValue
                self.lbl_BreakType.text    = resVal["break_type"].stringValue
                self.txt_WorkerNote.text   = resVal["note"].stringValue
                self.lbl_OutletName.text   = self.strOutletName
                self.outletView.isHidden   = self.strOutletiD.isEmpty
                
                // MARK: — Data fields
                self.strJobTypeName      = resVal["job_type"].stringValue
                self.strJobId            = resVal["job_type_id"].stringValue
                self.strBreak            = resVal["break_type"].stringValue
                self.strMeal             = resVal["meals"].stringValue
                self.shiftType           = resVal["shift_type"].stringValue
                self.workerCount         = Int(resVal["worker_count"].stringValue) ?? 1
                self.strStartTime        = resVal["start_time"].stringValue
                self.strEndTime          = resVal["end_time"].stringValue
                self.strBreakTime        = resVal["break_time"].stringValue
                self.strApplyForAllWorker = resVal["apply_time_same_for_allworkers"].stringValue
                self.strSchedule         = "Fill"
                
                // MARK: — Shift status
                if resVal["shiftStatus"].stringValue.isEmpty {
                    self.strShiftStatus = resVal["shift_brodcast_week_days"].arrayValue
                        .map { $0["shiftStatus"].stringValue }
                        .joined(separator: ",")
                } else {
                    self.strShiftStatus = resVal["shiftStatus"].stringValue
                }
                
                // MARK: — Schedule type UI + strDaysName
                // NOTE: strDaysName is set inside each branch, NOT before, to avoid overwrites
                switch self.shiftType {
                    
                case "Normal":
                    self.strDaysName              = ""
                    self.lbl_SelectSchedule.text  = "Weekly"
                    self.lbl_SelectDay.text       = "Select Days"
                    self.lbl_DefaultRate.text     = "Default Weekly Rate"
                    self.lbl_Note.isHidden        = true
                    self.dateSelectionVw.isHidden = false
                    self.arraySingleDate          = []
                    self.arrayOfDays              = []
                    self.collectionDate.isHidden  = true
                    self.timeSlot_HeightConstraint.constant = 0
                    
                case "SingleDate":
                    self.lbl_SelectSchedule.text  = "Specific Date"
                    self.lbl_DefaultRate.text     = "Default Date or Date Rate"
                    self.lbl_Note.isHidden        = true
                    self.dateSelectionVw.isHidden = false
                    
                    // Reset SingleDate state instead of pre-filling
                    self.arraySingleDate          = []
                    self.arrayOfDays              = []
                    self.strDaysName              = ""
                    self.lbl_SelectDay.text       = "Select Date"
                    self.collectionDate.isHidden  = true
                    self.timeSlot_HeightConstraint.constant = 0
                    
                default: // Broadcast / Urgent
                    self.strDaysName              = Utility.getCurrentDay()
                    self.lbl_SelectSchedule.text  = "Urgent"
                    self.lbl_SelectDay.text       = "Today"
                    self.lbl_SelectDay.textColor  = .darkGray
                    self.lbl_DefaultRate.text     = "Default Urgent Rate"
                    self.lbl_Note.isHidden        = false
                    self.dateSelectionVw.isHidden = false
                    self.arraySingleDate          = []
                    self.arrayOfDays              = []
                    self.collectionDate.isHidden  = true
                    self.timeSlot_HeightConstraint.constant = 0
                }
                
                // MARK: — Worker time array (single source of truth)
                let multiWorkTime = resVal["shift_multi_work_time"].arrayValue
                self.fullFetchedShiftArrayFromAPI = multiWorkTime
                
                if self.strApplyForAllWorker == "Yes" {
                    self.btn_ToAllWorkerOt.setImage(#imageLiteral(resourceName: "Checked"), for: .normal)
                    self.btn_ToAllWorkerOt.isSelected = true
                    
                    // One row — same time for all workers
                    let singleEntry: JSON = [
                        "work_start_time": multiWorkTime.first?["work_start_time"].stringValue ?? self.strStartTime ?? "",
                        "work_end_time":   multiWorkTime.first?["work_end_time"].stringValue   ?? self.strEndTime   ?? ""
                    ]
                    self.arrayWorkerTime        = [singleEntry]
                    self.workerShiftVw.isHidden = false
                    
                } else {
                    self.btn_ToAllWorkerOt.setImage(#imageLiteral(resourceName: "RectangleUncheck"), for: .normal)
                    self.btn_ToAllWorkerOt.isSelected = false
                    
                    if multiWorkTime.count > 0 {
                        self.arrayWorkerTime = multiWorkTime
                    } else {
                        let obj: JSON = [
                            "work_start_time": self.strStartTime ?? "",
                            "work_end_time":   self.strEndTime   ?? ""
                        ]
                        self.arrayWorkerTime = Array(repeating: obj, count: max(self.workerCount, 1))
                    }
                    self.workerShiftVw.isHidden = (self.workerCount <= 1)
                }
                
                self.worker_TableHeight.constant = CGFloat(self.arrayWorkerTime.count * 85)
                self.worker_TableVw.reloadData()
                
            } else {
                // MARK: — Status 0: reset for fresh manual entry
                self.shiftType                          = ""
                self.strSchedule                        = ""
                self.lbl_WorkerNum.text                 = "1"
                self.workerCount                        = 1
                self.lbl_ProvidedMeal.text              = "Select Meal"
                self.strMeal                            = ""
                self.lbl_BreakType.text                 = "Select Break"
                self.strBreak                           = ""
                self.txt_WorkerNote.text                = ""
                self.strStartTime                       = ""
                self.strEndTime                         = ""
                self.strDaysName                        = ""
                self.arraySingleDate                    = []
                self.arrayOfDays                        = []
                self.collectionDate.isHidden            = true
                self.timeSlot_HeightConstraint.constant = 0
                self.arrayWorkerTime                    = [JSON(["work_start_time": "", "work_end_time": ""])]
                self.workerShiftVw.isHidden             = true
                self.worker_TableHeight.constant        = 85
                self.worker_TableVw.reloadData()
            }
            
        } catch {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME,
                                            andMessage: error.localizedDescription, on: self)
        }
        self.hideProgressBar()
    }
    
    func collectParamJobPost() {
        // Derive start/end times from arrayWorkerTime — single source of truth
        let startTimes: [String]
        let endTimes: [String]
        
        if strApplyForAllWorker == "Yes" {
            startTimes = Array(repeating: strStartTime ?? "", count: workerCount)
            endTimes   = Array(repeating: strEndTime   ?? "", count: workerCount)
        } else {
            startTimes = arrayWorkerTime.map { obj in
                obj["work_start_time"].string ?? obj["startTime"].string ?? ""
            }
            endTimes = arrayWorkerTime.map { obj in
                obj["work_end_time"].string ?? obj["endTime"].string ?? ""
            }
        }
        
        paramJobPostDict["user_id"]                        = USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramJobPostDict["job_type"]                       = strJobTypeName as AnyObject
        paramJobPostDict["job_type_id"]                    = strJobId as AnyObject
        paramJobPostDict["worker_count"]                   = workerCount as AnyObject
        paramJobPostDict["start_time"]                     = (strStartTime ?? "") as AnyObject
        paramJobPostDict["end_time"]                       = (strEndTime ?? "") as AnyObject
        paramJobPostDict["day_name"]                       = strDaysName as AnyObject
        paramJobPostDict["shiftStatus"]                    = strShiftStatus as AnyObject
        paramJobPostDict["break_type"]                     = strBreak as AnyObject
        paramJobPostDict["shift_type"]                     = shiftType as AnyObject
        paramJobPostDict["meals"]                          = strMeal as AnyObject
        paramJobPostDict["note"]                           = txt_WorkerNote.text as AnyObject
        paramJobPostDict["single_date"]                    = arraySingleDate.joined(separator: ",") as AnyObject
        paramJobPostDict["apply_time_same_for_allworkers"] = strApplyForAllWorker as AnyObject
        paramJobPostDict["multi_work_start_time"]          = startTimes.joined(separator: ",") as AnyObject
        paramJobPostDict["multi_work_end_time"]            = endTimes.joined(separator: ",") as AnyObject
        paramJobPostDict["shift_break_time"]               = strBreakTime as AnyObject
        paramJobPostDict["shift_break_time_in_min"]        = Utility.convertToMinutes(from: strBreakTime) as AnyObject
        paramJobPostDict["outlet_id"]                      = strOutletiD as AnyObject
        paramJobPostDict["business_name"]                  = strOutletName as AnyObject
        
        print("=== Job Post Params ===")
        print("Job Type     : \(strJobTypeName) | ID: \(strJobId)")
        print("Shift Type   : \(shiftType) | Schedule: \(strSchedule)")
        print("Workers      : \(workerCount) | Apply Same: \(strApplyForAllWorker)")
        print("Start Times  : \(startTimes)")
        print("End Times    : \(endTimes)")
        print("Days/Dates   : \(strDaysName)")
        print("Single Dates : \(arraySingleDate)")
        print("Break        : \(strBreak) | \(strBreakTime)")
        print("Meal         : \(strMeal)")
        print("Outlet       : \(strOutletName) | ID: \(strOutletiD)")
        print("=======================")
    }
}

// MARK: TABLE VIEW DELEGATES
extension PublishJobVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayWorkerTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkerShiftTimeCell", for: indexPath) as! WorkerShiftTimeCell
        let obj = self.arrayWorkerTime[indexPath.row]
        
        self.worker_TableHeight.constant = CGFloat(self.arrayWorkerTime.count * 85)
        cell.lbl_WorkerCount.text = "Worker #\(indexPath.row + 1)"
        
        // Read time from JSON — check both possible key names
        let startTime: String = obj["work_start_time"].string ?? obj["startTime"].string ?? (strStartTime ?? "")
        let endTime: String   = obj["work_end_time"].string   ?? obj["endTime"].string   ?? (strEndTime   ?? "")
        
        cell.btn_StartTimeOt.setTitle(startTime.isEmpty ? "Start Time" : startTime, for: .normal)
        cell.btn_EndTimeOt.setTitle(endTime.isEmpty     ? "End Time"   : endTime,   for: .normal)
        
        cell.cloStartTime = { [self] in
            datePickerTapped(strFormat: "HH:mm", mode: .time, type: "Time") { strTime in
                cell.btn_StartTimeOt.setTitle(strTime, for: .normal)
                
                if self.strApplyForAllWorker == "Yes" {
                    // Same time for all — update every entry
                    self.strStartTime = strTime
                    self.arrayWorkerTime = self.arrayWorkerTime.map { _ in
                        JSON(["work_start_time": strTime,
                              "work_end_time": self.strEndTime ?? ""])
                    }
                } else {
                    // Replace only this worker's entry
                    if indexPath.row == 0 { self.strStartTime = strTime }
                    var updated = self.arrayWorkerTime[indexPath.row]
                    updated["work_start_time"] = JSON(strTime)
                    self.arrayWorkerTime[indexPath.row] = updated
                }
                print("✅ arrayWorkerTime after start pick: \(self.arrayWorkerTime)")
            }
        }
        
        cell.cloEndTime = { [self] in
            datePickerTapped(strFormat: "HH:mm", mode: .time, type: "Time") { strTime in
                cell.btn_EndTimeOt.setTitle(strTime, for: .normal)
                
                if self.strApplyForAllWorker == "Yes" {
                    self.strEndTime = strTime
                    self.arrayWorkerTime = self.arrayWorkerTime.map { _ in
                        JSON(["work_start_time": self.strStartTime ?? "",
                              "work_end_time": strTime])
                    }
                } else {
                    if indexPath.row == 0 { self.strEndTime = strTime }
                    var updated = self.arrayWorkerTime[indexPath.row]
                    updated["work_end_time"] = JSON(strTime)
                    self.arrayWorkerTime[indexPath.row] = updated
                }
                print("✅ arrayWorkerTime after end pick: \(self.arrayWorkerTime)")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

// MARK: COLLECTION VIEW DELEGATES
extension PublishJobVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arraySingleDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiDateCell", for: indexPath) as! MultiDateCell
        cell.lbl_Date.text = self.arraySingleDate[indexPath.row]
        
        cell.cloCancel = {
            self.arraySingleDate.remove(at: indexPath.row)
            if indexPath.row < self.arrayOfDays.count {
                self.arrayOfDays.remove(at: indexPath.row)
            }
            // Keep strDaysName in sync
            self.strDaysName = self.arraySingleDate.joined(separator: ",")
            let numberOfRows = (self.arraySingleDate.count + 1) / 2
            self.timeSlot_HeightConstraint.constant = CGFloat(numberOfRows) * 50
            self.collectionDate.reloadData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionDate.frame.width / 2, height: 50)
    }
}
