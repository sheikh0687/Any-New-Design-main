//
//  UserRatingVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 08/10/25.
//

import UIKit
import Cosmos
import SwiftyJSON

class UserRatingVC: UIViewController {
    
    @IBOutlet weak var lbl_TotalRating: UILabel!
    @IBOutlet weak var ratingStar: CosmosView!
    @IBOutlet weak var lbl_TotalCount: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var arr_AllReviews:[JSON] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "UserRatingCell", bundle: nil), forCellReuseIdentifier: "UserRatingCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Review", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")

        if USER_DEFAULT.value(forKey: USERID) != nil {
            WebGetReview()
        }
        tableView.estimatedRowHeight = 180
        tableView.rowHeight = UITableView.automaticDimension
    }

    func WebGetReview() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["type"]  =  "USER" as AnyObject

        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_rating_review.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllReviews = swiftyJsonVar["result"].arrayValue
                    self.lbl_TotalRating.text = swiftyJsonVar["average_rating"].stringValue
                    self.lbl_TotalCount.text = "Based on \(swiftyJsonVar["total_rating_count"].stringValue) reviews"
                    self.ratingStar.rating = Double(swiftyJsonVar["average_rating"].stringValue) ?? 0.0

                    print(self.arr_AllReviews.count)
                    self.tableView.backgroundView = UIView()
                    self.tableView.reloadData()
                } else {
                    self.arr_AllReviews = []
                    self.tableView.backgroundView = UIView()
                    self.tableView.reloadData()
                    Utility.noDataFound("No Reviews At The Moment", tableViewOt: self.tableView, parentViewController: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }

}

extension UserRatingVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arr_AllReviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserRatingCell", for: indexPath) as! UserRatingCell
        
        let obj = self.arr_AllReviews[indexPath.row]
        
        print(obj["form_details"]["business_name"].stringValue)
        
        cell.lbl_Name.text = obj["form_details"]["business_name"].stringValue
        cell.lblAddress.text = obj["form_details"]["business_address"].stringValue
        cell.lblFeedback.text = obj["feedback"].stringValue
        cell.lblDateTime.text = obj["date_time"].stringValue
        cell.ratingStar.rating = Double(obj["rating"].stringValue) ?? 0.0
        
        if Router.BASE_IMAGE_URL != obj["form_details"]["image"].stringValue {
            Utility.setImageWithSDWebImage(obj["form_details"]["image"].stringValue, cell.clientImg)
        }
        
        return cell
    }
}
