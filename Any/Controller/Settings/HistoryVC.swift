//
//  HistoryVC.swift
//  Any
//
//  Created by mac on 30/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import Cosmos

class HistoryVC: UIViewController {
    
    @IBOutlet weak var lbl_JobsCount: UILabel!
    @IBOutlet weak var lbl_Earning: UILabel!
    @IBOutlet weak var table_List: UITableView!
    
    var arr_AllHistory:[JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
       
        self.navigationController?.navigationBar.isHidden = false
    
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "History", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")

        WebGetApprovedBooking()
        
        table_List.estimatedRowHeight = 200
        table_List.rowHeight = UITableView.automaticDimension
    }
}

//MARK: API
extension HistoryVC {
    
    func WebGetApprovedBooking() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["client_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject

        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_shift_complete_by_client.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                
                table_List.isHidden = false
                
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    self.lbl_Earning.text = "\(kCurrency) \(swiftyJsonVar["total_earning"].number ?? 0)"
                    self.lbl_JobsCount.text = "\(swiftyJsonVar["total_job"].number ?? 0)"
                    self.table_List.backgroundView = UIView()
                    
                    self.arr_AllHistory = swiftyJsonVar["result"].arrayValue
                    self.table_List.reloadData()
                } else {
                    self.arr_AllHistory = []
                    self.table_List.backgroundView = UIView()
                    self.table_List.reloadData()
                    Utility.noDataFound("No Transactions At The Moment", tableViewOt: self.table_List, parentViewController: self)
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
}

extension HistoryVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_AllHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookingCellWorker
            
        let dic = arr_AllHistory[indexPath.row]
        cell.lbl_DayDate.text = (dic["format_date"].stringValue) + " - " +  ("\(dic["user_details"]["first_name"].stringValue) \(dic["user_details"]["last_name"].stringValue)")
        cell.lbl_CompanyName.text = "\(dic["address"].stringValue)"
        
        let shiftTime = "\(dic["total_working_hr_time"].stringValue) Hour/Rate \(kCurrency)\(dic["shift_rate"].stringValue) = \(kCurrency)\(dic["total_amount"].stringValue)"
     
        
        let strTyp = dic["set_shift_details"]["break_type"].stringValue
        
        var strBr = ""
        
        if strTyp == "Not Aplicable" {
            strBr = "Break Type : Not Aplicable"
        } else {
            strBr = "\(strTyp) Break : \(dic["break_time"].stringValue)"

        }
        
        if strTyp == "Not Applicable" {
            strBr = "Break Type : Not Applicable"
        } else {
            strBr = "\(strTyp) Break : \(dic["break_time"].stringValue)"

        }

        if dic["rating_review_status"].stringValue == "Yes" {
            cell.view_GiveRating.isHidden = true
            cell.reviewView.isHidden = false
            cell.cosmosVw.rating = Double(dic["rating"].stringValue) ?? 0.0
            cell.lbl_Feedback.text = dic["review"].stringValue
        } else {
            cell.view_GiveRating.isHidden = false
            cell.reviewView.isHidden = true
        }
        
        cell.lbl_ShiftTime.text = shiftTime
        cell.lbl_Address.text = "Time-In \(dic["clock_in_time"].stringValue) / Time-Out \(dic["clock_out_time"].stringValue)\n\n\(strBr)"

        cell.btn_GiveRating.tag = indexPath.row
        cell.btn_GiveRating.addTarget(self, action: #selector(giveRating), for: .touchUpInside)

        return cell
        
    }
    
    @objc func giveRating(but: UIButton) {
        let dic = arr_AllHistory[but.tag]
        let vC = R.storyboard.main.addRatingReviewVC()!
        vC.strToid = dic["user_id"].stringValue
        vC.strRequestiD = dic["id"].stringValue
        self.navigationController?.pushViewController(vC, animated: true)
    }
}

extension HistoryVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}


