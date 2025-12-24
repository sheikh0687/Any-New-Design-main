//
//  SaveCardVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 18/04/24.
//

import UIKit
import SwiftyJSON

class SaveCardVC: UIViewController {
    
    @IBOutlet weak var saved_CardTableVw: UITableView!
    @IBOutlet weak var btn_AddNewCard: UIButton!
    
    var arr_AllCards:[JSON] = []
    var cloCardDetail:((_ cardId: String,_ customerId : String) -> Void)?
    
    var customer_Id:String?
    var card_Id:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.saved_CardTableVw.register(UINib(nibName: "SaveCardCell", bundle: nil), forCellReuseIdentifier: "SaveCardCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Save Cards", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        GetProfile()
    }
    
    @IBAction func btn_AddCard(_ sender: UIButton) {
        let vC = kStoryboardMain.instantiateViewController(withIdentifier: "PaymentVC") as! PaymentVC
        vC.customer_Id = customer_Id ?? ""
        self.navigationController?.pushViewController(vC, animated: true)
    }
}

extension SaveCardVC {
    
    func GetProfile() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_profile.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let obj = swiftyJsonVar["result"]
                    
                    let customerId = obj["customer_id"].stringValue
                    
                    guard !customerId.isEmpty else {
                        print("Customer ID is empty.")
                        self.hideProgressBar()
                        Utility.noDataFound("No Saved Cards At The Moment", tableViewOt: self.saved_CardTableVw, parentViewController: self)
                        return
                    }
                    
                    self.customer_Id = obj["customer_id"].stringValue
                    //                    self.card_Id = obj["card_id"].stringValue
                    
                    USER_DEFAULT.set(customerId, forKey: CUSTOMERID)
                    //                    USER_DEFAULT.set(cardId, forKey: CARDID)
                    
                    self.WebGetSavedCard()
                } else {
                    print(swiftyJsonVar["result"].string ?? "Unknown error")
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebGetSavedCard() {
        showProgressBar()
        
        guard let customerId = customer_Id else {
            print("Missing customer_Id.")
            Utility.noDataFound("No Saved Cards At The Moment", tableViewOt: self.saved_CardTableVw, parentViewController: self)
            hideProgressBar()
            return
        }

        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["customer_id"] = customerId as AnyObject
//        paramsDict["card_id"] = cardId as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.retrieve_all_card_stripe.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    print(swiftyJsonVar["result"])
                    self.arr_AllCards  = swiftyJsonVar["result"]["data"].arrayValue
                    print(self.arr_AllCards.count)
                    self.btn_AddNewCard.isHidden = true
                    self.saved_CardTableVw.backgroundView = UIView()
                    self.saved_CardTableVw.reloadData()
                } else {
                    self.arr_AllCards = []
                    self.btn_AddNewCard.isHidden = false
                    self.saved_CardTableVw.backgroundView = UIView()
                    self.saved_CardTableVw.reloadData()
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func delete_SavedCard(cardId: String) {
        var dict: [String : Any] = [:]
        dict["user_id"]     = USER_DEFAULT.value(forKey: USERID)
        dict["card_id"]     = cardId
        dict["customer_id"] = customer_Id
        
        print(dict)
        
        Api.shared.delete_SavedCard(self, dict) { responseData in
            self.parseDataSaveCard(apiResponse: responseData)
        }
    }
    
    func parseDataSaveCard(apiResponse : Any) {
        DispatchQueue.main.async {
            let swiftyJsonVar = JSON(apiResponse)
            print(swiftyJsonVar)
            if(swiftyJsonVar["status"] == "1") {
                print(swiftyJsonVar["result"]["id"].stringValue)
                Utility.showAlertWithAction(withTitle: APPNAME, message: "Card deleted successfully", delegate: nil, parentViewController: self, completionHandler: { (boool) in
                    self.WebGetSavedCard()
                    self.dismiss(animated: true)
                })
            } else {
                Utility.showAlertWithAction(withTitle: APPNAME, message: "Something went wrong", delegate: nil, parentViewController: self, completionHandler: { (boool) in
                })
            }
        }
    }
}

extension SaveCardVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_AllCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SaveCardCell", for: indexPath) as! SaveCardCell
        let obj = arr_AllCards[indexPath.row]
        
        cell.lbl_Card.text = "\(obj["brand"].stringValue)  **** **** **** \(obj["last4"].stringValue)"
        
        cell.cloDelete = { () in
            self.delete_SavedCard(cardId: obj["id"].stringValue)
        }
        
        cell.cloChoose = { () in
            self.cloCardDetail?(obj["id"].stringValue, obj["customer"].stringValue)
        }
        return cell
    }
}
