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
    
    var strJobTypeName:String = ""
    var strJobId:String = ""
    var workerCount:Int = 1
    
    var strStartTime:String! = ""
    var strEndTime:String! = ""
    var strBreak:String = ""
    var strSchedule:String = ""
    var strMeal:String = ""
    var shiftType:String = ""
    var strBreakTime:String = ""
    
    var strDaysName:String = ""
    var strShiftStatus:String = ""
    var strApplyForAllWorker:String = "No"
    var strOutletName: String = ""
    var strOutletiD: String = ""
    
    var arrayWorkerTime: [JSON] = []
    var arrayStartTime: [String] = []
    var arrayEndTime: [String] = []
    var fullFetchedShiftArrayFromAPI: [JSON] = []
//    var arrayOfOutlet: [JSON] = []
    
    var arrayWorkerStartTime: [String] = []
    var arrayWorkerEndTime: [String] = []
    var arraySingleDate:[String] = []
    var arrayOfDays: [String] = []
    
    var isFrom:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.worker_TableVw.register(UINib(nibName: "WorkerShiftTimeCell", bundle: nil), forCellReuseIdentifier: "WorkerShiftTimeCell")
        self.collectionDate.register(UINib(nibName: "MultiDateCell", bundle: nil), forCellWithReuseIdentifier: "MultiDateCell")
        self.arrayWorkerTime.append(JSON(workerCount))
        print(self.arrayWorkerTime.count)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        WebGetOutlet()
        print(USER_DEFAULT.value(forKey: OUTLET_NAME) as? String ?? "")
        print(USER_DEFAULT.value(forKey: CLIENTID) as? String ?? "")
        self.lbl_OutletName.text = USER_DEFAULT.value(forKey: OUTLET_NAME) as? String ?? ""
        self.strOutletiD = USER_DEFAULT.value(forKey: CLIENTID) as? String ?? ""
        self.strOutletName = USER_DEFAULT.value(forKey: OUTLET_NAME) as? String ?? ""
    }
    
    @IBAction func btn_OutletName(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Outlet"
        vC.centerTitle = "Outlet Selection"
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
        vC.cloAllJobTypes = { valJobType, jobiD in
            self.lbl_JobType.text = valJobType
            self.strJobTypeName = valJobType
            self.strJobId = jobiD
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_WorkerNum(_ sender: UIButton) {
        let vC = R.storyboard.main.selectAllJobTypesVC()!
        vC.headline = "Number of Workers"
        vC.centerTitle = "Manpower"
        vC.cloAllJobTypes = { valWorkerCount, valBlank in
            self.lbl_WorkerNum.text = valWorkerCount
            self.workerCount = Int(valWorkerCount) ?? 0
            
            guard let workerCount = Int(valWorkerCount), workerCount > 0 else {
                print("Invalid string value or count is zero.")
                return
            }
            
            if workerCount > self.arrayWorkerTime.count {
                let increaseCol = workerCount - self.arrayWorkerTime.count
                for _ in 0..<increaseCol {
                    let obj: [String: String] = ["startTime": "", "endTime": ""]
                    self.arrayWorkerTime.append(JSON(obj))
                }
            } else if workerCount < self.arrayWorkerTime.count {
                let decreaseCol = self.arrayWorkerTime.count - workerCount
                for _ in 0..<decreaseCol {
                    self.arrayWorkerTime.removeLast()
                }
            }
            
            self.workerShiftVw.isHidden = (workerCount <= 1)
            self.worker_TableHeight.constant = CGFloat(self.arrayWorkerTime.count * 85)
            self.worker_TableVw.reloadData()
        }
        self.navigationController?.pushViewController(vC, animated: true)
    }
    
    @IBAction func btn_Schedule(_ sender: UIButton) {
        if isFrom != "Urgent" {
            let vC = R.storyboard.main.selectAllJobTypesVC()!
            strSchedule = "Fill"
            vC.headline = "Schedule"
            vC.centerTitle = "Schedule Selection"
            vC.cloAllJobTypes = { valJobType, valBlank in
                if valJobType == "Weekly" {
                    self.lbl_SelectSchedule.text = valJobType
                    self.lbl_SelectDay.text = "Select Days"
                    self.lbl_DefaultRate.text = "Default Weekly Rate"
                    self.lbl_Note.isHidden = true
                    self.shiftType = "Normal"
                } else if valJobType == "Specific Date" {
                    self.lbl_SelectSchedule.text = valJobType
                    self.lbl_SelectDay.text = "Select Date"
                    self.lbl_DefaultRate.text = "Default Date Or Date Rate"
                    self.lbl_Note.isHidden = true
                    self.shiftType = "SingleDate"
                } else {
                    self.lbl_SelectSchedule.text = "Urgent"
                    self.lbl_SelectDay.text = "Today"
                    self.lbl_DefaultRate.text = "Default Urgent Rate"
                    self.lbl_SelectDay.textColor = .darkGray
                    self.lbl_Note.isHidden = false
                    self.shiftType = "Broadcast"
                    self.strDaysName = Utility.getCurrentDay()
                }
                self.dateSelectionVw.isHidden = false
                self.timeSlot_HeightConstraint.constant = 0
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
            vC.cloAllJobTypes = { valDays, valShiftShatus in
                self.lbl_SelectDay.text = valDays
                self.strDaysName = valDays
                self.strShiftStatus = valShiftShatus
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
            print(valBreak)
            print(valBlank)
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
            // Uncheck
            sender.isSelected = false
            sender.setImage(R.image.uncheck(), for: .normal)
            strApplyForAllWorker = "No"
            
            // Restore timeSelectionBeans based on worker count
            //            if let count = strWorkerNumb, count > 0 {
            if workerCount > arrayWorkerTime.count {
                let increaseCol = workerCount - arrayWorkerTime.count
                for _ in 0..<increaseCol {
                    let bean = TimeSelectionBean()
                    bean.startTime = ""
                    bean.endTime = ""
                    arrayWorkerTime.append(JSON(bean))
                }
            } else if workerCount < arrayWorkerTime.count {
                let decreaseCol = arrayWorkerTime.count - workerCount
                for _ in 0..<decreaseCol {
                    arrayWorkerTime.removeLast()
                }
            }
            //            }
            
        } else {
            // Check
            sender.isSelected = true
            sender.setImage(#imageLiteral(resourceName: "Checked"), for: .normal)
            strApplyForAllWorker = "Yes"
            
            // Clear and add only one shift time for all
            arrayWorkerTime.removeAll()
            let bean = TimeSelectionBean()
            bean.startTime = strStartTime
            bean.endTime = strEndTime
            arrayWorkerTime.append(JSON(bean))
            self.arrayStartTime.removeAll()
            let workerCount = Int(self.workerCount)
            for _ in 0..<workerCount {
                self.arrayStartTime.append(strStartTime)
            }
            print(self.arrayStartTime)
            self.arrayEndTime.removeAll()
            for _ in 0..<workerCount {
                self.arrayEndTime.append(strEndTime)
            }
            print(self.arrayEndTime)
        }
        
        // Update UI
        //        self.workerShiftVw.isHidden = (arrayWorkerShiftTime.count <= 1)
        self.worker_TableHeight.constant = CGFloat(arrayWorkerTime.count * 85)
        self.worker_TableVw.reloadData()
        
    }
    
    @IBAction func btn_PublishJob(_ sender: UIButton) {
        if isValidInput() {
            let vC = R.storyboard.main.confirmJobPostVC()!
            vC.strJobiD = strJobId
            collectParamJobPost()
            print(paramJobPostDict)
            self.navigationController?.pushViewController(vC, animated: true)
        }
    }
    
    func isValidInput() -> Bool {
        print("strApplyForAllWorker: '\(strApplyForAllWorker)'")
        print("workerCount: \(workerCount)")
        print("arrayStartTime.count: \(arrayStartTime.count)")
        print("arrayEndTime.count: \(arrayEndTime.count)")
        
        var errorMessage: String?
        
        if strJobTypeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Job Type"
        } else if strSchedule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select The Schedule"
        } else if strBreak.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Break Type"
        } else if strMeal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Meal"
        } else if shiftType == "Normal" && strDaysName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Days"
        } else if shiftType == "SingleDate" && arraySingleDate.count == 0 {
            errorMessage = "Please Select Date"
        } else if strApplyForAllWorker == "No" {
            if workerCount > arrayStartTime.count {
                errorMessage = "Please Select Time"
            } else if workerCount > arrayEndTime.count {
                errorMessage = "Please Select Time"
            }
        } else if strStartTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Time"
        } else if strEndTime.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Please Select Time"
        }
        
        if let message = errorMessage {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message, on: self)
            return false
        }
        
        return true
    }
}

extension PublishJobVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayWorkerTime.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkerShiftTimeCell", for: indexPath) as! WorkerShiftTimeCell
        
        self.worker_TableHeight.constant = CGFloat(self.arrayWorkerTime.count * 85)
        cell.lbl_WorkerCount.text = "Worker #\(String(indexPath.row + 1))"
        
        if indexPath.row == 0 {
            let startTime = strStartTime
            let endTime = strEndTime
            
            cell.btn_StartTimeOt.setTitle(startTime!.isEmpty ? "Start Time" : startTime, for: .normal)
            cell.btn_EndTimeOt.setTitle(endTime!.isEmpty ? "End Time" : endTime, for: .normal)
        }
        
        cell.cloStartTime = { [self] in
            datePickerTapped(strFormat: "HH:mm", mode: .time, type: "Time") { strTime in
                cell.btn_StartTimeOt.setTitle(strTime, for: .normal)
                
                if indexPath.row == 0 {
                    self.strStartTime = strTime
                }
                if self.strApplyForAllWorker == "Yes" {
                    self.arrayStartTime.removeAll()
                    for _ in 0..<self.workerCount {
                        self.arrayStartTime.append(strTime)
                        self.fullFetchedShiftArrayFromAPI.append(JSON(strTime))
                    }
                } else {
                    self.arrayStartTime.append(strTime)
                }
                
                print(self.arrayStartTime)
                
            }
        }
        
        cell.cloEndTime = { [self] in
            datePickerTapped(strFormat: "HH:mm", mode: .time, type: "Time") { strTime in
                cell.btn_EndTimeOt.setTitle(strTime, for: .normal)
                
                if indexPath.row == 0 {
                    self.strEndTime = strTime
                }
                if self.strApplyForAllWorker == "Yes" {
                    self.arrayEndTime.removeAll()
                    for _ in 0..<self.workerCount {
                        self.arrayEndTime.append(strTime)
                        self.fullFetchedShiftArrayFromAPI.append(JSON(strTime))
                    }
                } else {
                    self.arrayEndTime.append(strTime)
                }
                
                print(self.arrayEndTime)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}

extension PublishJobVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arraySingleDate.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiDateCell", for: indexPath) as! MultiDateCell
        cell.lbl_Date.text = self.arraySingleDate[indexPath.row]
        
        cell.cloCancel = {
            self.arraySingleDate.remove(at: indexPath.row)
            self.arrayOfDays.remove(at: indexPath.row)
            let numberOfItemsInRow = 2
            let numberOfRows = (self.arraySingleDate.count + numberOfItemsInRow - 1) / numberOfItemsInRow
            let cellHeight: CGFloat = 50
            self.timeSlot_HeightConstraint.constant = CGFloat(numberOfRows) * cellHeight
            self.collectionDate.reloadData()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionDate.frame.width/2, height: 50)
    }
}

extension PublishJobVC {
    
    func WebGetOutlet() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_Outlet.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.outletView.isHidden = false
                } else {
                    self.outletView.isHidden = true
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func collectParamJobPost()
    {
        paramJobPostDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramJobPostDict["job_type"]     =  strJobTypeName  as AnyObject
        paramJobPostDict["job_type_id"]     =  strJobId  as AnyObject
        paramJobPostDict["worker_count"]     =  workerCount  as AnyObject
        paramJobPostDict["start_time"]     =  strStartTime  as AnyObject
        paramJobPostDict["end_time"]     =  strEndTime  as AnyObject
        paramJobPostDict["day_name"]     =  strDaysName  as AnyObject
        paramJobPostDict["shiftStatus"]     =  strShiftStatus  as AnyObject
        paramJobPostDict["break_type"]     =  strBreak  as AnyObject
        paramJobPostDict["shift_type"]     =  shiftType  as AnyObject
        paramJobPostDict["meals"]     =  strMeal  as AnyObject
        paramJobPostDict["note"]  =   self.txt_WorkerNote.text! as AnyObject
        paramJobPostDict["single_date"] = arraySingleDate.joined(separator: ",") as AnyObject
        
        paramJobPostDict["apply_time_same_for_allworkers"] = strApplyForAllWorker as AnyObject
        paramJobPostDict["multi_work_start_time"] = self.arrayStartTime.joined(separator: ",") as AnyObject
        paramJobPostDict["multi_work_end_time"] = self.arrayEndTime.joined(separator: ",") as AnyObject
        paramJobPostDict["shift_break_time"] = self.strBreakTime as AnyObject
        paramJobPostDict["shift_break_time_in_min"] = Utility.convertToMinutes(from: strBreakTime) as AnyObject
        paramJobPostDict["outlet_id"] = strOutletiD as AnyObject
        paramJobPostDict["business_name"] = strOutletName as AnyObject
        
        print(paramJobPostDict)
    }
}

//=http://52.220.103.59/Any/webservice/set_shift?&user_id=2117&job_type=F%26B%20Service%20Crew&job_type_id=1&worker_count=2&start_time=&end_time=&day_name=Monday%2CTuesday%2CWednesday%2CThursday%2CFriday%2CSaturday%2CSunday&shiftStatus=Yes%2CYes%2CYes%2CYes%2CYes%2CYes%2CYes&break_type=Unpaid&meals=Not%20Provided&note=Thai%20shift%20to%20test%20new%20break%20time%20module&shift_type=Normal&apply_time_same_for_allworkers=Yes&single_date=&multi_work_start_time=10%3A00%2C&multi_work_end_time=18%3A00%2C&previous_worker_id=&shift_break_time=2%20hours%2C%2030%20mins&shift_break_time_in_min=150
