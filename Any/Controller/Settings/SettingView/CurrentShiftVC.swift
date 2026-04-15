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
import SwiftUI

class CurrentShiftVC: UIViewController {
    
    @IBOutlet weak var btn_Switch: UISwitch!
    @IBOutlet weak var btn_SwicthAutoApprove: UISwitch!
    @IBOutlet weak var table_list: UITableView!
    
    var arr_List:[JSON] = []
    
    var strDate:String! = ""
    var strlat:String! = ""
    var strlon:String! = ""
    
    let refreshControl = UIRefreshControl()
    var drop = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table_list.register(UINib(nibName: "CurrentShiftCell", bundle: nil), forCellReuseIdentifier: "CurrentShiftCell")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        table_list.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Settings", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
        table_list.estimatedRowHeight = 200
        table_list.rowHeight = UITableView.automaticDimension
        
        Task {
            await getDataGetList()
            await GetProfile()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func refreshData() {
        Task {
            await getDataGetList()
            refreshControl.endRefreshing()
        }
    }
    
    @IBAction func switchClos(_ sender: Any) {
        if kappDelegate.dicProdile["booking_status"].stringValue == "Close" {
           Task {
               await getDataGetChatListd(strType: "Open")
            }
        } else {
           Task {
               await getDataGetChatListd(strType: "Close")
            }
        }
    }
    
    @IBAction func switchAutoApproval(_ sender: Any) {
        if kappDelegate.dicProdile["shift_autoapproval"].stringValue == "No" {
           Task {
               await getShiftAutoApproval(strType: "Yes")
            }
        } else {
           Task {
               await getShiftAutoApproval(strType: "No")
            }
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
    
    func GetProfile() async {
        
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["device_id"]  =   USER_DEFAULT.value(forKey: IOS_TOKEN) as AnyObject
        
        print(paramsDict)
        
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.get_profile.url(), parameters: paramsDict, parentViewController: self)
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
        } catch {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        }
        
        hideProgressBar()
    }
    
    func getDataGetChatListd(strType:String) async {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["booking_status"]  =   strType as AnyObject
                
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.update_booking_status_profile.url(), parameters: paramDict, parentViewController: self)
            if(swiftyJsonVar["status"].stringValue == "1") {
               Task {
                   await self.GetProfile()
                }
            }
        } catch {
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
        }
        
        hideProgressBar()
    }
    
    func getShiftAutoApproval(strType:String) async {
        
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["shift_autoapproval"]  =   strType as AnyObject
        
        print(paramDict)
            
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.set_shift_autoapproval_status.url(), parameters: paramDict, parentViewController: self)
            if(swiftyJsonVar["status"].stringValue == "1") {
                Task {
                   await self.GetProfile()
                }
            } else {
                Task {
                   await self.GetProfile()
                }
                self.alert(alertmessage: swiftyJsonVar["message"].stringValue)
            }
        } catch {
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
        }
        
        hideProgressBar()
    }
    
    func getDataGetList() async {
        
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["shift_type"]  =   "Normal" as AnyObject
        
        print(paramDict)
                
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.get_my_set_shift.url(), parameters: paramDict, parentViewController: self)
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
        } catch {
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
        }
        
        hideProgressBar()
    }
    
    func webDeletShift(strSt:String) async {
        
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["id"]  =   strSt as AnyObject
        
        print(paramDict)
                
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.delete_my_shifts.url(), parameters: paramDict, parentViewController: self)
            if(swiftyJsonVar["status"].stringValue == "1") {
                Task {
                   await self.getDataGetList()
                }
            } else {
                print("Something went wrong")
//                await self.getDataGetList()
//                Utility.showAlertMessage(withTitle: EMPTY_STRING, message: swiftyJsonVar["message"].stringValue, delegate: nil,parentViewController: self)
            }
        } catch {
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
        }
        
        hideProgressBar()
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
        
//        cell.cloDots = { [weak self] in
//            self?.showMenu(for: indexPath, button: cell.btn_ThreeDot)
//        }
  
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
                let swiftUIView = CurrentShiftAlertView(popFor: "Update") { confirmed in
                    if confirmed {
                        let vc = R.storyboard.main.updateJobPublishVC()!
                        vc.shift_iD = dic["id"].stringValue
                        vc.strOutletiD = dic["outlet_id"].stringValue
                        vc.strOutletName = dic["business_name"].stringValue
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                self.presentSwiftUIAlert(swiftUIView)
            } else {
//               Task {
//                   await webDeletShift(strSt: dic["id"].stringValue)
//                }
                let swiftUIView = CurrentShiftAlertView(popFor: "Delete") { confirmed in
                    if confirmed {
                        Task {
                            print(dic["id"].stringValue)
                            await self.webDeletShift(strSt: dic["id"].stringValue)
                        }
                    }
                }
                self.presentSwiftUIAlert(swiftUIView)
            }
        }
    }
    
    func showMenu(for indexPath: IndexPath, button: UIButton) {

        let dic = arr_List[indexPath.row]
        print(dic)

        let updateAction = UIAction(title: "Update") { [weak self] _ in
            guard let self else { return }

            let swiftUIView = CurrentShiftAlertView(popFor: "Update") { confirmed in
                if confirmed {
                    let vc = R.storyboard.main.updateJobPublishVC()!
                    vc.shift_iD = dic["id"].stringValue
                    vc.strOutletiD = dic["outlet_id"].stringValue
                    vc.strOutletName = dic["business_name"].stringValue
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }

            self.presentSwiftUIAlert(swiftUIView)
        }

        let deleteAction = UIAction(title: "Delete", attributes: .destructive) { [weak self] _ in
            guard let self else { return }

            let swiftUIView = CurrentShiftAlertView(popFor: "Delete") { confirmed in
                if confirmed {
                    Task {
                        print(dic["id"].stringValue)
                        await self.webDeletShift(strSt: dic["id"].stringValue)
                    }
                }
            }

            self.presentSwiftUIAlert(swiftUIView)
        }

        let menu = UIMenu(title: "", children: [deleteAction, updateAction])

        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
    
    func presentSwiftUIAlert(_ view: some View) {

        let hostingVC = UIHostingController(rootView: view)
        hostingVC.modalPresentationStyle = .overFullScreen
        hostingVC.modalTransitionStyle = .crossDissolve
        hostingVC.view.backgroundColor = .clear

        present(hostingVC, animated: true)
    }
    
//    @objc func clcidelete(but:UIButton)  {
//        
//        let dic = arr_List[but.tag]
//        print(dic)
//        
//        let updateAction = UIAction (
//            title: "Update"
//        ) { [weak self] _ in
//            guard let self else { return }
//            
//            let swiftUIView = CurrentShiftAlertView(popFor: "Update") { confirmed in
//                if confirmed {
//                    let vc = R.storyboard.main.updateJobPublishVC()!
//                    vc.shift_iD = dic["id"].stringValue
//                    vc.strOutletiD = dic["outlet_id"].stringValue
//                    vc.strOutletName = dic["business_name"].stringValue
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//            
//            let hostingVC = UIHostingController(rootView: swiftUIView)
//            hostingVC.modalPresentationStyle = .overFullScreen
//            hostingVC.modalTransitionStyle = .crossDissolve
//            hostingVC.view.backgroundColor = .clear
//            
//            self.present(hostingVC, animated: true)
//        }
//        
//        let deleteAction = UIAction (
//            title: "Delete",
//            attributes: .destructive
//        ) { [weak self] _ in
//            guard let self else { return }
//            
//            let swiftUIView = CurrentShiftAlertView(popFor: "Delete") { confirmed in
//                if confirmed {
//                   Task {
//                       print(dic["id"].stringValue)
//                       await self.webDeletShift(strSt: dic["id"].stringValue)
//                    }
//                }
//            }
//            
//            let hostingVC = UIHostingController(rootView: swiftUIView)
//            hostingVC.modalPresentationStyle = .overFullScreen
//            hostingVC.modalTransitionStyle = .crossDissolve
//            hostingVC.view.backgroundColor = .clear
//            
//            self.present(hostingVC, animated: true)
//        }
//        
//        let menu = UIMenu(title: "", children: [deleteAction, updateAction])
//        
//        but.menu = menu
//        but.showsMenuAsPrimaryAction = true
//    }
    
}

extension CurrentShiftVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


