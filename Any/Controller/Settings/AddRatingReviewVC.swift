//
//  AddRatingReviewVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 09/10/25.
//

import UIKit
import Cosmos
import SwiftyJSON

class AddRatingReviewVC: UIViewController {

    @IBOutlet weak var ratingStar: CosmosView!
    @IBOutlet weak var txt_RatingReview: UITextView!
    
    var strRequestiD: String = ""
    var strToid: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txt_RatingReview.addHint("Enter your feedback here...")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Add Review", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_Submit(_ sender: UIButton) {
        if ratingStar.rating.isZero {
            self.alert(alertmessage: "Please select the rating")
        } else if txt_RatingReview.text == "" {
            self.alert(alertmessage: "Please enter the feedback")
        } else {
            WebAddReview()
        }
    }

    func WebAddReview() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["from_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["to_id"]  =  strToid as AnyObject
        paramsDict["rating"]  =  ratingStar.rating as AnyObject
        paramsDict["feedback"]  =  txt_RatingReview.text as AnyObject
        paramsDict["request_id"]  =  strRequestiD as AnyObject

        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.add_user_rating_review.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    Utility.showAlertWithAction(withTitle: APPNAME, message: "Rating added successfully", delegate: nil, parentViewController: self) { bool in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}
