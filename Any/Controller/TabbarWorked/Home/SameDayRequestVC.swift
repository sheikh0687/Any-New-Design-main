//
//  SameDayRequestVC.swift
//  Any
//
//  Created by mac on 09/06/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Cosmos

class SameDayRequestCell: UITableViewCell {
    
    @IBOutlet weak var lbl_BusinessNameAndTime: UILabel!
    @IBOutlet weak var lbl_ShiftRate: UILabel!
    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_MEal: UILabel!
    @IBOutlet weak var lbl_Note: UILabel!
    @IBOutlet weak var lbl_Location: UILabel!
    @IBOutlet weak var btn_Decline: UIButton!
    @IBOutlet weak var btn_Accept: UIButton!
    
}

class SameDayRequestVC: UIViewController, FooTwoViewControllerDelegate {
  
    @IBOutlet weak var table_List: UITableView!
    
    var arr_AllDriver:[JSON] = []
    var strId:String! = ""
    var strStatus = "Pending"
    var strDate = ""
    var dicCrent:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table_List.estimatedRowHeight = 188
        table_List.rowHeight = UITableView.automaticDimension
    }

    override func viewWillAppear(_ animated: Bool) {
       
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Urgent Booking", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
       
        WebGetApprovedBooking()

    }

    func myVCDidFinish(text: String) {
        
        if text == "Accept" {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                WebRejectBooking(strCard: "Accept")

            }


        } else if text == "Reject" {
            webDeletShift(strSt: dicCrent["id"].stringValue)
        } else if text == "Message" {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                
                let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "UserChat") as! UserChat
                objVC.receiverId = kappDelegate.dicCrent["client_details"]["id"].stringValue
                objVC.userName = (kappDelegate.dicCrent["client_details"]["first_name"].stringValue) + " " + (kappDelegate.dicCrent["client_details"]["last_name"].stringValue)
                objVC.strReasonID = kappDelegate.dicCrent["client_details"]["id"].stringValue
                self.navigationController?.pushViewController(objVC, animated: true)

            }
        } else if text == "Confirm" {
       //     WebRejectBooking(strCard: "1")

            self.WebGetApprovedBooking()

        }
    }
    
    //MARK: API
   
    func WebRejectBooking(strCard:String) {
      
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["client_id"]  =   dicCrent["client_details"]["id"].stringValue as AnyObject
        paramsDict["shift_id"]  =   dicCrent["id"].stringValue as AnyObject
        paramsDict["day_name"]  =   dicCrent["day_name"].stringValue as AnyObject
        paramsDict["date"]  =   dicCrent["date"].stringValue as AnyObject

        showProgressBar()

        CommunicationManager.callPostService(apiUrl: Router.add_to_set_shift_cart_broadcast.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)

                if(swiftyJsonVar["status"].stringValue == "1") {
              
                    if strCard == "Accept" {
                        let sdsd = kappDelegate.dicCrent["start_time"].stringValue

                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpBookingConfirmVC") as! PopUpBookingConfirmVC
                        objVC.str_Desc = "Your shift will start at (\(sdsd)) today at this location:"
                        objVC.str_Sub_Desc = "\(kappDelegate.dicCrent["client_details"]["business_name"].stringValue), \(kappDelegate.dicCrent["address"].stringValue)\n\n\(kCurrency)\(kappDelegate.dicCrent["shift_rate"].stringValue)/Hour"
                        objVC.str_Sub_Desc2 = "\(kappDelegate.dicCrent["job_type"].stringValue)\n\(kappDelegate.dicCrent["note"].stringValue)"
                        objVC.delegate = self
                        objVC.modalPresentationStyle = .overCurrentContext
                        objVC.modalTransitionStyle = .crossDissolve
                        self.present(objVC, animated: false, completion: nil)

                    } else  {
                        self.WebGetApprovedBooking()
                    }
                } else {
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: swiftyJsonVar["message"].stringValue, on: self)
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }

    func WebGetApprovedBooking() {
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["status"]  =   strStatus as AnyObject
        paramsDict["date"]  =   strDate as AnyObject

        showProgressBar()

        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_broadcast_shift.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
              
                table_List.isHidden = false

                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    self.arr_AllDriver = swiftyJsonVar["result"].arrayValue
                    self.table_List.backgroundView = UIView()
                    self.table_List.reloadData()
                    
                } else {
                    
                    self.arr_AllDriver = []
                    self.table_List.backgroundView = UIView()
                    self.table_List.reloadData()
                    Utility.noDataFound("No Requests At The Moment", tableViewOt: self.table_List, parentViewController: self)
                }
                
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
        paramDict["worker_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["shift_id"]  =   strSt as AnyObject

        CommunicationManager.callPostService(apiUrl: Router.shift_rejected_by_worker.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.WebGetApprovedBooking()
                    
                    let shiftTime = "\(dicCrent["start_time"].stringValue) to \(dicCrent["end_time"].stringValue)"

                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpRejectVC") as! PopUpRejectVC
                    objVC.str_Desc = "\(dicCrent["client_details"]["business_name"].stringValue),  \(dicCrent["address"].stringValue)\n\(dicCrent["day_name"].stringValue), \(shiftTime)"
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


}


extension SameDayRequestVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_AllDriver.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SameDayRequestCell
            
        let dic = arr_AllDriver[indexPath.row]

        cell.lbl_BusinessNameAndTime.text = "\(dic["client_details"]["business_name"].stringValue), (\(dic["start_time"].stringValue) - \(dic["end_time"].stringValue))\nToday"
        
        cell.lbl_ShiftRate.text = "\(dic["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue)/Hour"
        
        cell.lbl_JobType.text = "Job Type : \(dic["job_type"].stringValue)"
        cell.lbl_Break.text = "Break : \(dic["break_type"].stringValue)"
        cell.lbl_MEal.text = "Meals : \(dic["meals"].stringValue)"
        cell.lbl_Note.text = "Note : \(dic["note"].stringValue)"
        cell.lbl_Location.text = "Location : \(dic["address"].stringValue)"
        
        cell.btn_Accept.tag = indexPath.row
        cell.btn_Accept.addTarget(self, action: #selector(clciBookApprove), for: .touchUpInside)

        cell.btn_Decline.tag = indexPath.row
        cell.btn_Decline.addTarget(self, action: #selector(clcidReject), for: .touchUpInside)

        return cell
    }
    
    @objc func clciBookApprove(but:UIButton)  {
       
        let dic = arr_AllDriver[but.tag]
        dicCrent = dic
        kappDelegate.dicCrent = dic

        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpSameVC") as! PopUpSameVC
        objVC.str_Head = "\(dic["client_details"]["business_name"].stringValue), \(dic["address"].stringValue)\n\n\(kCurrency)\(dic["shift_rate"].stringValue)/Hour"

        objVC.str_Desc = "Break : \(dic["break_type"].stringValue)\n\nMeals : \(dic["meals"].stringValue)"
        objVC.str_Sub_Desc = "\(dic["job_type"].stringValue)\n\n\(dic["note"].stringValue)"
        objVC.delegate = self
        objVC.strFrom = "Accept"
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.present(objVC, animated: false, completion: nil)
    }
    
    @objc func clcidReject(but:UIButton)  {
        let dic = arr_AllDriver[but.tag]
        dicCrent = dic
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpSameVC") as! PopUpSameVC
        objVC.str_Head = "\(dic["client_details"]["business_name"].stringValue), \(dic["address"].stringValue)\n\n\(kCurrency)\(dic["shift_rate"].stringValue)/Hour"

        objVC.str_Desc = "Break : \(dic["break_type"].stringValue)\n\nMeals : \(dic["meals"].stringValue)"
        objVC.str_Sub_Desc = "\(dic["job_type"].stringValue)\n\n\(dic["note"].stringValue)"
        objVC.delegate = self
        objVC.strFrom = "Reject"
        objVC.modalPresentationStyle = .overCurrentContext
        objVC.modalTransitionStyle = .crossDissolve
        self.present(objVC, animated: false, completion: nil)
    }
}

extension SameDayRequestVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


    }
}




