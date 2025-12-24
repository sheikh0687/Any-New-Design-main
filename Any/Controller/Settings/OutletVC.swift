//
//  OutletVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 17/11/25.
//

import UIKit
import SwiftyJSON
import DropDown

class OutletVC: UIViewController {

    @IBOutlet weak var outletTableVw: UITableView!
    
    var arrayOutletList: [JSON] = []
    var drop = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.outletTableVw.register(UINib(nibName: "AddOutletCell", bundle: nil), forCellReuseIdentifier: "AddOutletCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "My Outlets", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
        WebGetOutlet()
    }
    
    @IBAction func btn_AddOutlet(_ sender: UIButton) {
        let vC = R.storyboard.main.addOutletVC()!
        isComeOutlet = false
        self.navigationController?.pushViewController(vC, animated: true)
    }
}

extension OutletVC {
    
    func WebGetOutlet() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
    
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_Outlet.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrayOutletList = swiftyJsonVar["result"].arrayValue
                    print(self.arrayOutletList.count)
                    self.outletTableVw.backgroundView = UIView()
                    self.outletTableVw.reloadData()
                    
                } else {
                    self.arrayOutletList = []
                    self.outletTableVw.backgroundView = UIView()
                    self.outletTableVw.reloadData()
                    Utility.noDataFound("No outlet At The Moment", tableViewOt: self.outletTableVw, parentViewController: self)
                }
                
                self.hideProgressBar()
                
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func webDeletOutlet(strSt:String) {
        
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   strSt as AnyObject
        
        CommunicationManager.callPostService(apiUrl: Router.delete_Outlet.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.WebGetOutlet()
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

extension OutletVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayOutletList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddOutletCell", for: indexPath) as! AddOutletCell
        let obj = self.arrayOutletList[indexPath.row]
        cell.lbl_OutletName.text = obj["business_name"].stringValue
        cell.lbl_OutletAddress.text = "Address: \(obj["business_address"].stringValue)"
        
        if Router.BASE_IMAGE_URL != obj["business_logo"].stringValue {
            Utility.setImageWithSDWebImage(obj["business_logo"].stringValue, cell.outletImg)
        } else {
            cell.outletImg.image = UIImage(named: "no_image")
        }
        
        cell.btn_ThreeDot.tag = indexPath.row
        cell.btn_ThreeDot.addTarget(self, action: #selector(clUpdateDelete), for: .touchUpInside)
        
        return cell
    }
    
    @objc func clUpdateDelete(but:UIButton)  {
      
        let dic = arrayOutletList[but.tag]
       
        drop.anchorView = but
        drop.dataSource =  ["Update","Delete"]
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in

            if index == 0 {
                let vC = R.storyboard.main.addOutletVC()!
                isComeOutlet = true
                vC.strOutletiD = dic["id"].stringValue
                vC.outletName = dic["business_name"].stringValue
                vC.outletAddress = dic["business_address"].stringValue
                vC.outletImage = dic["business_logo"].stringValue
                vC.outletLat = dic["lat"].stringValue
                vC.outletLon = dic["lon"].stringValue
                self.navigationController?.pushViewController(vC, animated: true)
            } else {
                webDeletOutlet(strSt: dic["id"].stringValue)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indeexPath: IndexPath) -> CGFloat {
        return 100
    }
}
