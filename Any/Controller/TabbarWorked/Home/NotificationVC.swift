//


import UIKit
import SwiftyJSON
import SDWebImage
import Cosmos

class notiCell:UITableViewCell {
    @IBOutlet weak var cosmosV: CosmosView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Desc: UILabel!
    @IBOutlet weak var lbl_DAte: UILabel!
    @IBOutlet weak var lbl_ReqID: UILabel!
}

class NotificationVC: UIViewController {
    
    @IBOutlet weak var table_News: UITableView!
    var arr_AllCat:[JSON] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Notification", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")

        if USER_DEFAULT.value(forKey: USERID) != nil {
            WebGetCategory()
        }
        table_News.estimatedRowHeight = 100
        table_News.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    //MARK:API
    func WebGetCategory() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["type"]  =  "USER" as AnyObject

        print(paramsDict)
        CommunicationManager.callPostService(apiUrl: Router.get_notification_list.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllCat = swiftyJsonVar["result"].arrayValue
                    print(self.arr_AllCat.count)
                    self.table_News.backgroundView = UIView()
                    self.table_News.reloadData()
                } else {
                    self.arr_AllCat = []
                    self.table_News.backgroundView = UIView()
                    self.table_News.reloadData()
                    Utility.noDataFound("No Notifications At The Moment", tableViewOt: self.table_News, parentViewController: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
}
extension NotificationVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_AllCat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! notiCell
        
        let dic = arr_AllCat[indexPath.row]
        
        cell.lbl_Title.text = (dic["message"].stringValue)
        cell.lbl_ReqID.text = (dic["date_time"].stringValue)
        
        return cell
    }
}

extension NotificationVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = self.arr_AllCat[indexPath.row]
//        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "OrderDetailVC") as! OrderDetailVC
//        objVC.strReId = dic["request_id"].stringValue
//        self.navigationController?.pushViewController(objVC, animated: true)

    }
}
