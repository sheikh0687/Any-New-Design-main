//
//  SettingHomeVC.swift
//  Any
//
//  Created by mac on 30/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import DropDown

class CurrentShiftVC: UIViewController {

    @IBOutlet weak var btn_Switch: UISwitch!
    @IBOutlet weak var btn_SwicthAutoApprove: UISwitch!
    @IBOutlet weak var table_list: UITableView!
    
    var arr_List:[JSON] = []

    var strDate:String! = ""
    var strlat:String! = ""
    var strlon:String! = ""
    var drop = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.table_list.register(UINib(nibName: "CurrentShiftCell", bundle: nil), forCellReuseIdentifier: "CurrentShiftCell")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Settings", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
        table_list.estimatedRowHeight = 200
        table_list.rowHeight = UITableView.automaticDimension

        getDataGetList()
        GetProfile()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func switchClos(_ sender: Any) {
        if kappDelegate.dicProdile["booking_status"].stringValue == "Close" {
            getDataGetChatListd(strType: "Open")
        } else {
            getDataGetChatListd(strType: "Close")
        }
    }
    
    @IBAction func switchAutoApproval(_ sender: Any) {
        if kappDelegate.dicProdile["shift_autoapproval"].stringValue == "No" {
            getShiftAutoApproval(strType: "Yes")
        } else {
            getShiftAutoApproval(strType: "No")
        }
    }
    
    @IBAction func admin(_ sender: Any) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "listAdminVC") as! listAdminVC
        objVC.strType = "OutletAdmin"
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func authorized(_ sender: Any) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "listAdminVC") as! listAdminVC
        objVC.strType = "AuthrisedApprover"
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    func GetProfile() {

        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["device_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject

        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_profile.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let dic = swiftyJsonVar["result"]
                    kappDelegate.dicProdile = dic
                    if kappDelegate.dicProdile["booking_status"].stringValue == "Close" {
                        btn_Switch.setOn(true, animated: true)
                    } else {
                        btn_Switch.setOn(false, animated: true)
                    }
                    
                    if kappDelegate.dicProdile["shift_autoapproval"].stringValue == "No" {
                        btn_SwicthAutoApprove.setOn(false, animated: true)
                    } else {
                        btn_SwicthAutoApprove.setOn(true, animated: true)
                    }
                }
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func getDataGetChatListd(strType:String) {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["booking_status"]  =   strType as AnyObject

        CommunicationManager.callPostService(apiUrl: Router.update_booking_status_profile.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.GetProfile()
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func getShiftAutoApproval(strType:String) {
        
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["shift_autoapproval"]  =   strType as AnyObject

        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.set_shift_autoapproval_status.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.GetProfile()
                } else {
                    self.GetProfile()
                    self.alert(alertmessage: swiftyJsonVar["message"].stringValue)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func getDataGetList() {
        
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["shift_type"]  =   "Normal" as AnyObject

        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_my_set_shift.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_List  = swiftyJsonVar["result"].arrayValue
                    self.table_list.backgroundView = UIView()
                    self.table_list.reloadData()
                } else {
                    self.arr_List = []
                    self.table_list.backgroundView = UIView()
                    self.table_list.reloadData()
                    Utility.noDataFound("No Shifts At The Moment", tableViewOt: self.table_list, parentViewController: self)
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
                    self.getDataGetList()
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

extension CurrentShiftVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_List.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentShiftCell", for: indexPath) as! CurrentShiftCell
      
        let dic = self.arr_List[indexPath.row]
        
        if dic["shift_type"].stringValue == "Normal" {
            cell.lbl_AvailableDays.text = (dic["day_name"].stringValue)
        } else if dic["shift_type"].stringValue == "SingleDate" {
            cell.lbl_AvailableDays.text = (dic["single_date"].stringValue)
        } else {
            cell.lbl_AvailableDays.text = "Urgent"
        }

        cell.lbl_StartEndTime.text = "\(dic["start_time"].stringValue) to \(dic["end_time"].stringValue)"

        cell.lbl_Break.text = (dic["break_type"].stringValue)
        cell.lbl_Meal.text = (dic["meals"].stringValue)
        cell.lbl_JobType.text = (dic["job_type"].stringValue)
        cell.lbl_OUtletName.text = (dic["business_name"].stringValue)
        
        cell.btn_ThreeDot.tag = indexPath.row
        cell.btn_ThreeDot.addTarget(self, action: #selector(clcidelete), for: .touchUpInside)

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
                let vC = R.storyboard.main.updateJobPublishVC()!
                vC.shift_iD = dic["id"].stringValue
                vC.strOutletiD = dic["outlet_id"].stringValue
                vC.strOutletName = dic["business_name"].stringValue
                self.navigationController?.pushViewController(vC, animated: true)
            } else {
                webDeletShift(strSt: dic["id"].stringValue)
            }
        }
    }
}

extension CurrentShiftVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}


