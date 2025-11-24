//
//  WishlistVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 24/09/25.
//

import UIKit
import SwiftyJSON

class WishlistVC: UIViewController {

    @IBOutlet weak var wishlistTableVw: UITableView!
    var arrayList: [JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wishlistTableVw.register(UINib(nibName: "ClientListCell", bundle: nil), forCellReuseIdentifier: "ClientListCell")
        getClientList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "", CenterTitle: "Favorite Clients", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }

}

extension WishlistVC {
    
    func getClientList() {
        showProgressBar()
        
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["lat"]  =   kappDelegate.CURRENT_LAT as AnyObject
        paramDict["lon"]  =   kappDelegate.CURRENT_LON as AnyObject
        paramDict["finddate"]  =   Utility.getCurrentShortDate() as AnyObject
        paramDict["day_name"]  =   Utility.getCurrentDay() as AnyObject
        paramDict["cat_id"]  =   "0" as AnyObject
//        paramDict["client_job_type_id"]  =   "0" as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_fav_client_list.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrayList  = swiftyJsonVar["result"].arrayValue
                    self.wishlistTableVw.backgroundView = UIView()
                    self.wishlistTableVw.reloadData()
                } else {
                    self.arrayList = []
                    self.wishlistTableVw.backgroundView = UIView()
                    self.wishlistTableVw.reloadData()
                    Utility.noDataFound("No Wishlist At The Moment", tableViewOt: self.wishlistTableVw, parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
}

extension WishlistVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientListCell", for: indexPath) as! ClientListCell
        
        let dic = self.arrayList[indexPath.row]
        
        cell.lbl_BusinessName.text = (dic["business_name"].stringValue)
        cell.lbl_Address.text = "Address: \(dic["business_address"].stringValue)"
        
        if Router.BASE_IMAGE_URL != dic["business_logo"].stringValue {
            Utility.setImageWithSDWebImage(dic["business_logo"].stringValue, cell.clientLogo_Img)
        } else {
            cell.clientLogo_Img.image = R.image.placeholder_2()
        }
        
        if dic["booking_status"].stringValue == "Open" {
            cell.lbl_AvailbaleStatus.text = "Available"
            cell.lbl_AvailbaleStatus.textColor = hexStringToUIColor(hex: "#04a431")
        } else {
            cell.lbl_AvailbaleStatus.text = "Not Available"
            cell.lbl_AvailbaleStatus.textColor = hexStringToUIColor(hex: "#AEACAC")
        }
        
        if dic["shift_autoapproval"].stringValue == "Yes" {
            cell.lbl_InstantApproval.isHidden = false
        } else {
            cell.lbl_InstantApproval.isHidden = true
        }
        
        cell.btn_LikeOt.setImage(R.image.fav_add(), for: .normal)
        return cell
    }
}
