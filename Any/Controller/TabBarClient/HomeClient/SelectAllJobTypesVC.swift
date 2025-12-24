//
//  SelectAllJobTypesVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 10/10/24.
//

import UIKit
import SwiftyJSON
import DropDown

class SelectAllJobTypesVC: UIViewController {
    
    @IBOutlet weak var lbl_Type: UILabel!
    @IBOutlet weak var jobTypes_TableVw: UITableView!
    @IBOutlet weak var btnPublishJobOt: UIButton!
    @IBOutlet weak var jobTableHeight: NSLayoutConstraint!
    @IBOutlet weak var brekTimeVw: UIStackView!
    
    var headline:String = ""
    var centerTitle = ""
    var strBreakType:String = ""
    
    var isFromUpdate:Bool!
    
    var arrayOfJobType:[JSON] = []
    var arrayOfSchedule:[String] = ["Specific Date", "Weekly", "Same-Day Booking (Urgent)"]
    var arrayOfWorkerNum:[String] = ["1", "2", "3","4","5","6","7","8","9","10"]
    var arrayOfBreakType:[String] = ["Paid", "Unpaid", "Not Applicable"]
    var arrayOfMeal:[String] = ["Provided", "Not Provided"]
    var arr_ShiftStu:[String] = ["No","No","No","No","No","No","No"]
    var arr_DaysName:[String] = []
    var arrayOfDaysSelection:[String] = []
    
    var arrayOfWeekDays:[JSON] = []
    var arrayOfOutletName: [JSON] = []
    var drop = DropDown()
    
    var cloAllJobTypes:((_ valType: String,_ valiD:String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbl_Type.text = headline
        self.jobTypes_TableVw.register(UINib(nibName: "AllJobTypeCell", bundle: nil), forCellReuseIdentifier: "AllJobTypeCell")
        if headline == "Outlet" {
            WebGetOutlet()
        } else if headline == "Job Type" {
            WebGetCategory()
        } else if headline == "Days" {
            if isFromUpdate {
                btnPublishJobOt.isHidden = false
                let shiftStatus = self.arrayOfWeekDays.filter({$0["shiftStatus"].stringValue == "Yes"})
                print(shiftStatus)
                self.arrayOfDaysSelection = shiftStatus.map({$0["day_name"].stringValue})
                print(arrayOfDaysSelection)
                self.arr_DaysName = self.arrayOfWeekDays.map({$0["day_name"].stringValue})
                print(arr_DaysName)
                self.arr_ShiftStu = arrayOfWeekDays.map({$0["shiftStatus"].stringValue})
                print(arr_ShiftStu)
            } else {
                WebGetWeekDays()
                btnPublishJobOt.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: centerTitle, CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_PublishJob(_ sender: UIButton) {
        
        var arrFDays:[String] = []
        for i in 0..<arr_ShiftStu.count {
            
            if arr_ShiftStu[i] == "Yes" {
                arrFDays.append(arr_DaysName[i])
            }
        }
        
        if arrayOfDaysSelection.count > 0 {
            self.cloAllJobTypes?(arrFDays.joined(separator: ","), arr_ShiftStu.joined(separator: ","))
            self.navigationController?.popViewController(animated: true)
        } else {
            self.alert(alertmessage: "Please select the days")
        }
    }
    
    @IBAction func btn_BreakTime(_ sender: UIButton) {
        drop.anchorView = sender
        drop.dataSource =  ["1 hour","1 hour, 30 mins","2 hours","2 hours, 30 mins","3 hours"]
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            self.cloAllJobTypes?(self.strBreakType, item)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension SelectAllJobTypesVC {
    
    func WebGetOutlet() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_Outlet.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrayOfOutletName = swiftyJsonVar["result"].arrayValue
                    self.jobTypes_TableVw.reloadData()
                } else {
                    print("Something Went Wrong")
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebGetCategory() {
        showProgressBar()
        let paramsDict:[String:AnyObject] = [:]
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_job_type.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrayOfJobType = swiftyJsonVar["result"].arrayValue
                    self.jobTableHeight.constant = CGFloat(self.arrayOfJobType.count * 40)
                    print(self.arrayOfJobType.count)
                    self.jobTypes_TableVw.reloadData()
                } else {
                    let message = swiftyJsonVar["result"].string
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message!, on: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebGetWeekDays() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_client_weekly_rate.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrayOfWeekDays = swiftyJsonVar["result"].arrayValue
                    self.arr_DaysName = self.arrayOfWeekDays.map({$0["day_name"].stringValue})
                    
                    print(self.arrayOfWeekDays.count)
                    self.jobTableHeight.constant = CGFloat(self.arrayOfWeekDays.count * 40)
                    
                    self.jobTypes_TableVw.reloadData()
                } else {
                    let message = swiftyJsonVar["result"].string
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message!, on: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}

extension SelectAllJobTypesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headline == "Outlet" {
            return arrayOfOutletName.count
        } else if headline == "Job Type" {
            return arrayOfJobType.count
        } else if headline == "Schedule" {
            return arrayOfSchedule.count
        } else if headline == "Number of Workers" {
            return arrayOfWorkerNum.count
        } else if headline == "Break Type" {
            return arrayOfBreakType.count
        } else if headline == "Meal Provision" {
            return arrayOfMeal.count
        } else {
            return arrayOfWeekDays.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllJobTypeCell", for: indexPath) as! AllJobTypeCell
        if headline == "Outlet" {
            let obj = self.arrayOfOutletName[indexPath.row]
            cell.lbl_Name.text = obj["business_name"].stringValue
        } else if headline == "Job Type" {
            let obj = self.arrayOfJobType[indexPath.row]
            cell.lbl_Name.text = obj["name"].stringValue
        } else if headline == "Schedule" {
            cell.lbl_Name.text = self.arrayOfSchedule[indexPath.row]
            self.jobTableHeight.constant = CGFloat(self.arrayOfSchedule.count * 40)
        } else if headline == "Number of Workers" {
            cell.lbl_Name.text = self.arrayOfWorkerNum[indexPath.row]
            self.jobTableHeight.constant = CGFloat(self.arrayOfWorkerNum.count * 40)
        } else if headline == "Break Type" {
            cell.lbl_Name.text = self.arrayOfBreakType[indexPath.row]
            self.jobTableHeight.constant = CGFloat(self.arrayOfBreakType.count * 40)
        } else if headline == "Meal Provision" {
            cell.lbl_Name.text = self.arrayOfMeal[indexPath.row]
            self.jobTableHeight.constant = CGFloat(self.arrayOfMeal.count * 40)
        } else {
            let obj = self.arrayOfWeekDays[indexPath.row]
            cell.lbl_Name.text = obj["day_name"].stringValue
            
            if arrayOfDaysSelection.contains(obj["day_name"].stringValue) {
                cell.img_Selected.isHidden = false
                cell.lbl_Name.textColor = #colorLiteral(red: 0.137254902, green: 0.7215686275, blue: 0.831372549, alpha: 1)
            } else {
                cell.img_Selected.isHidden = true
                cell.lbl_Name.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if headline == "Outlet" {
            let obj = self.arrayOfOutletName[indexPath.row]
            self.cloAllJobTypes?(obj["business_name"].stringValue, obj["id"].stringValue)
            self.navigationController?.popViewController(animated: true)
        } else if headline == "Job Type" {
            let obj = self.arrayOfJobType[indexPath.row]
            self.cloAllJobTypes?(obj["name"].stringValue, obj["id"].stringValue)
            self.navigationController?.popViewController(animated: true)
        } else if headline == "Schedule" {
            self.cloAllJobTypes?(self.arrayOfSchedule[indexPath.row], EMPTY_STRING)
            self.navigationController?.popViewController(animated: true)
        } else if headline == "Number of Workers" {
            self.cloAllJobTypes?(self.arrayOfWorkerNum[indexPath.row], EMPTY_STRING)
            self.navigationController?.popViewController(animated: true)
        } else if headline == "Break Type" {
            if indexPath.row == 2 {
                self.cloAllJobTypes?(self.arrayOfBreakType[indexPath.row], EMPTY_STRING)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.strBreakType = self.arrayOfBreakType[indexPath.row]
                self.brekTimeVw.isHidden = false
            }
        } else if headline == "Meal Provision" {
            self.cloAllJobTypes?(self.arrayOfMeal[indexPath.row], EMPTY_STRING)
            self.navigationController?.popViewController(animated: true)
        } else {
            let obj = self.arrayOfWeekDays[indexPath.row]
            if arrayOfDaysSelection.contains(obj["day_name"].stringValue) {
                arrayOfDaysSelection.removeAll(where: {$0 == obj["day_name"].stringValue})
                arr_ShiftStu[indexPath.row] = "No"
            } else {
                arrayOfDaysSelection.append(obj["day_name"].stringValue)
                arr_ShiftStu[indexPath.row] = "Yes"
            }
            jobTypes_TableVw.reloadData()
        }
    }
}
