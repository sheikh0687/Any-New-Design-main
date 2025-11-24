//
//  SetRateVC.swift
//  Any
//
//  Created by mac on 03/06/23.
//

import UIKit
import SwiftyJSON
import DropDown

class SetRateVC: UIViewController {
    
    @IBOutlet weak var lbl_UrgentRateIs: UILabel!
    @IBOutlet weak var lbl_MinimumRate: UILabel!
    @IBOutlet weak var weeklyRateCollectionVw: UICollectionView!
    @IBOutlet weak var weeklyCollectionHeight: NSLayoutConstraint!
    
    @IBOutlet weak var specificDateCollectionVw: UICollectionView!
    @IBOutlet weak var specificDateCollectionHeight: NSLayoutConstraint!
    
    var arr_AllWeekRate:[JSON] = []
    var arr_CheckDayStatus:[String] = []
    var arr_AllDayRate:[String] = []
    
    var dicJONS:JSON!
    
    var arr_AllSpecificRate: [JSON] = []
    var arr_DateRate: [String] = []
    var arr_AllCustomDate: [String] = []
    
    var minRate:Int! = 0
    var dayRate:Int! = 0
    var urgentRate:Int! = 0
    var weekDayRate:Int! = 0
    var specificDateRate:Int! = 0
    
    var checkValues:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.weeklyRateCollectionVw.register(UINib(nibName: "WeeklyRateCell", bundle: nil),forCellWithReuseIdentifier: "WeeklyRateCell")
        self.specificDateCollectionVw.register(UINib(nibName: "WeeklyRateCell", bundle: nil),forCellWithReuseIdentifier: "WeeklyRateCell")
        WebGetShiftStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Rates", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        WebGetDateRate()
    }
    
    @IBAction func plusMinimum(_ sender: Any) {
        minRate += 1
        self.lbl_MinimumRate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.minRate!)/h"
    }
    
    @IBAction func minusMinimum(_ sender: Any) {
        if minRate > 1 {
            minRate -= 1
            lbl_MinimumRate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.minRate!)/h"
        }
    }
    
    @IBAction func urgentPluss(_ sender: Any) {
        urgentRate += 1
        self.lbl_UrgentRateIs.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.urgentRate!)/h"
        
    }
    
    @IBAction func urgentMinus(_ sender: Any) {
        if urgentRate > 1 {
            urgentRate -= 1
            lbl_UrgentRateIs.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.urgentRate!)/h"
        }
    }
    
    @IBAction func SaveReturn(_ sender: UIButton) {
        WebAddShift()
    }
    
    @IBAction func btn_SetSpecificDate(_ sender: UIButton) {
        let vC = R.storyboard.main().instantiateViewController(withIdentifier: "SetCustomDateRateVC") as! SetCustomDateRateVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
}

//MARK: API
extension SetRateVC {
    
    func WebGetShiftStatus() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_client_weekly_rate.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.dicJONS = swiftyJsonVar
                    
                    self.minRate = Int(self.dicJONS["min_day_rate"].stringValue)!
                    //                    self.dayRate = Int(self.dicJONS["ticked_day_rate"].stringValue)!
                    self.urgentRate = Int(self.dicJONS["urgent_rate"].stringValue)!
                    
                    self.lbl_MinimumRate.text =  "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.minRate!)/h"
                    self.lbl_UrgentRateIs.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(self.urgentRate!)/h"
                    
                    self.arr_AllWeekRate = swiftyJsonVar["result"].arrayValue
                    
//                    let arr = self.arr_AllWeekRate.filter({$0["check_status"].stringValue == "Yes"})
                    self.arr_AllDayRate = self.arr_AllWeekRate.map({$0["rate"].stringValue})
                    self.arr_CheckDayStatus = self.arr_AllWeekRate.map({$0["check_status"].stringValue})
                    
                    self.weeklyCollectionHeight.constant = CGFloat(self.arr_AllWeekRate.count * 40)
                    self.weeklyRateCollectionVw.reloadData()
                    
                } else {
                    
                    let message = swiftyJsonVar["message"].string
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message!, on: self)
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebGetDateRate() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_client_date_rate.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllSpecificRate = swiftyJsonVar["result"].arrayValue
                    self.specificDateCollectionHeight.constant = CGFloat(self.arr_AllSpecificRate.count * 40)
                    self.arr_DateRate = self.arr_AllSpecificRate.map({$0["rate"].stringValue})
                    self.arr_AllCustomDate = self.arr_AllSpecificRate.map({$0["date"].stringValue})
                    
                    self.specificDateCollectionVw.reloadData()
                    self.specificDateCollectionVw.isHidden = false
                } else {
                    let message = swiftyJsonVar["message"].string
                    print(message ?? "")
                    self.arr_AllSpecificRate = []
                    self.specificDateCollectionVw.isHidden = true
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebAddShift() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["day_name"]     =  self.arr_AllWeekRate.map({$0["day_name"].stringValue}).joined(separator: ",")  as AnyObject
        paramsDict["min_day_rate"]     =  minRate  as AnyObject
        paramsDict["ticked_day_rate"]     =  dayRate  as AnyObject
        paramsDict["check_status"]     =  arr_CheckDayStatus.joined(separator: ",")  as AnyObject
        paramsDict["urgent_rate"]     = urgentRate  as AnyObject
        paramsDict["rate"]     = arr_AllDayRate.joined(separator: ",")   as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.add_client_weekly_rate.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    if self.arr_AllSpecificRate.count > 0 {
                        self.WebUpdateDateShifts()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    let message = swiftyJsonVar["message"].string
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message!, on: self)
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebUpdateDateShifts() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["day_name"]     =  "" as AnyObject
        paramsDict["rate"]     = arr_DateRate.joined(separator: ",")   as AnyObject
        paramsDict["date"]     = arr_AllCustomDate.joined(separator: ",")  as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.update_client_date_rate.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
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
    
    func WebDeleteDateRate(_ dateiD:String) {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["id"]  =  dateiD as AnyObject

        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.delete_client_date_rate.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.WebGetDateRate()
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

extension SetRateVC: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == weeklyRateCollectionVw {
            return arr_AllWeekRate.count
        } else {
            return arr_AllSpecificRate.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeeklyRateCell", for: indexPath) as! WeeklyRateCell
        
        if collectionView == weeklyRateCollectionVw {
            let obj = self.arr_AllWeekRate[indexPath.row]
            
            cell.btn_DeleteOt.isHidden = true
            cell.lbl_DayName.text = obj["day_name"].stringValue
            cell.lbl_Rate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(obj["rate"].stringValue)/h"
            
            cell.cloPlus = {
                var rateVal = Int(self.arr_AllWeekRate[indexPath.row]["rate"].stringValue) ?? 0
                rateVal += 1
                self.arr_AllWeekRate[indexPath.row]["rate"] = JSON(rateVal) // Update the model
                self.arr_AllDayRate[indexPath.row] = String(rateVal)
                cell.lbl_Rate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(rateVal)/h"
            }
            
            cell.cloMinus = { [self] in
                var rateVal = Int(self.arr_AllWeekRate[indexPath.row]["rate"].stringValue) ?? 0
                if rateVal > 1 {
                    rateVal -= 1
                    self.arr_AllWeekRate[indexPath.row]["rate"] = JSON(rateVal) // Update the model
                    self.arr_AllDayRate[indexPath.row] = String(rateVal)
                    cell.lbl_Rate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(rateVal)/h"
                }
            }
            
        } else {
            let obj = self.arr_AllSpecificRate[indexPath.row]
            
            cell.btn_DeleteOt.isHidden = false
            cell.lbl_DayName.text = obj["date"].stringValue
            cell.lbl_Rate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(obj["rate"].numberValue)/h"
            
            let dateRate = obj["rate"].numberValue
            self.specificDateRate = Int(truncating: dateRate)
            
            cell.cloPlus = {
                var rateVal = Int(self.arr_AllSpecificRate[indexPath.row]["rate"].stringValue) ?? 0
                rateVal += 1
                self.arr_AllSpecificRate[indexPath.row]["rate"] = JSON(rateVal) // Update the model
                self.arr_DateRate[indexPath.row] = String(rateVal)
                cell.lbl_Rate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(rateVal)/h"
            }
            
            cell.cloMinus = { [self] in
                var rateVal = Int(self.arr_AllSpecificRate[indexPath.row]["rate"].stringValue) ?? 0
                if rateVal > 1 {
                    rateVal -= 1
                    self.arr_AllSpecificRate[indexPath.row]["rate"] = JSON(rateVal) // Update the model
                    self.arr_DateRate[indexPath.row] = String(rateVal)
                    cell.lbl_Rate.text = "\(kappDelegate.dic_Profile["currency_symbol"].stringValue)\(rateVal)/h"
                }
            }
            
            cell.cloDelete = { [self] in
                self.WebDeleteDateRate(obj["id"].stringValue)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionWidth = collectionView.frame.width
        let collectionHeight = collectionView.frame.height
        return CGSize(width: collectionWidth, height: collectionHeight)
    }
}


