//
//  listAdminVC.swift
//  Any
//
//  Created by mac on 02/06/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import DropDown

class listAdminVC: UIViewController {
    
    @IBOutlet weak var table_Chat: UITableView!
    
    var arr_List:[JSON] = []
    
    var strType:String! = "OutletAdmin"
    var strlat:String! = ""
    var strlon:String! = ""
    var drop = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getDataGetChatList()
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: strType, CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
    }
    
    @IBAction func pluss(_ sender: Any) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "AddAdminVC") as! AddAdminVC
        objVC.strType = strType
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    func getDataGetChatList() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["type"]  =   strType as AnyObject
        
        CommunicationManager.callPostService(apiUrl: Router.get_OutletAdmin_AuthrisedApprover.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_List  = swiftyJsonVar["result"].arrayValue
                    self.table_Chat.backgroundView = UIView()
                    
                    self.table_Chat.reloadData()
                } else {
                    self.arr_List = []
                    self.table_Chat.backgroundView = UIView()
                    self.table_Chat.reloadData()
                    Utility.noDataFound("No Authrisers At The Moment", tableViewOt: self.table_Chat, parentViewController: self)
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
        paramDict["user_id"]  =   strSt as AnyObject
        
        CommunicationManager.callPostService(apiUrl: Router.delete_OutletAdmin_AuthrisedApprover.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.getDataGetChatList()
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
extension listAdminVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_List.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! urgentTableCell
        
        let dic = self.arr_List[indexPath.row]
        
        cell.lbl_jobtype.text = "\(dic["first_name"].stringValue) \(dic["last_name"].stringValue)"
        
        if strType == "AuthrisedApprover" {
            cell.lbl_Rate.text = "Authrised Approver"
        } else {
            cell.lbl_Rate.text = "Outlet Admin"
        }
        
        cell.btn_Three.tag = indexPath.row
        cell.btn_Three.addTarget(self, action: #selector(clcidelete), for: .touchUpInside)
        
        return cell
        
    }
    
    @objc func clcidelete(but:UIButton)  {
        let dic = arr_List[but.tag]
        drop.anchorView = but
        drop.dataSource =  ["Delete"]
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            webDeletShift(strSt: dic["id"].stringValue)
        }
    }
    
}

extension listAdminVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


