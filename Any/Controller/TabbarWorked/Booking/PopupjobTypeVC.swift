//
//  PopupjobTypeVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 24/09/25.
//

import UIKit
import SwiftyJSON

class PopupjobTypeVC: UIViewController {

    @IBOutlet weak var jobTypeTableVw: UITableView!
    
    var arr_AllCat: [JSON] = []
    var cloJobType: ((String, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.jobTypeTableVw.register(UINib(nibName: "AllJobTypeCell", bundle: nil), forCellReuseIdentifier: "AllJobTypeCell")
        WebGetJobCategory()
    }
    
    @IBAction func btn_Cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension PopupjobTypeVC {
    
    func WebGetJobCategory() {
        let paramsDict:[String:AnyObject] = [:]
        
        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_job_type.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllCat  = swiftyJsonVar["result"].arrayValue
                    self.jobTypeTableVw.backgroundView = UIView()
                    self.jobTypeTableVw.reloadData()
                } else {
                    self.arr_AllCat = []
                    self.jobTypeTableVw.backgroundView = UIView()
                    self.jobTypeTableVw.reloadData()
                    Utility.noDataFound("No Bookings At The Moment", tableViewOt: self.jobTypeTableVw, parentViewController: self)
                }
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }

}

extension PopupjobTypeVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_AllCat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllJobTypeCell", for: indexPath) as! AllJobTypeCell
        let obj = self.arr_AllCat[indexPath.row]
        cell.lbl_Name.text = obj["name"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.arr_AllCat[indexPath.row]
        self.cloJobType?(obj["name"].stringValue, obj["id"].stringValue)
        self.dismiss(animated: true)
    }
}
