

import UIKit
import SwiftyJSON
import SDWebImage
import Cosmos

class ChatConversationCell: UITableViewCell {
    
    @IBOutlet weak var lbl_Status: UILabel!
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnAcc: UIButton!
    @IBOutlet weak var img_Check: UIImageView!
    @IBOutlet weak var ratView: CosmosView!
//    @IBOutlet weak var lbl_Count: UILabel!
    @IBOutlet weak var img_User: UIImageView!
    @IBOutlet weak var lbl_UserBName: UILabel!
    @IBOutlet weak var lbl_TimeAgo: UILabel!
    @IBOutlet weak var lbl_Message: UILabel!
    @IBOutlet weak var messageNotify: UIImageView!
    
}

class ChatConversationVC: UIViewController {
    
    @IBOutlet weak var table_Chat: UITableView!
    
    var arr_List:[JSON] = []
    var strReason = ""
    var strReasonID = ""
    var strGroup = "Chat"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table_Chat.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Message", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        getDataGetChatList()
    }
    
    func getDataGetChatList() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["receiver_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["type"]  =   "" as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_conversation_detail.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
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
                    Utility.noDataFound("No Chat", tableViewOt: self.table_Chat, parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
}
extension ChatConversationVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_List.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatConversationCell
        let dic = self.arr_List[indexPath.row]
        
        cell.lbl_UserBName.text = (dic["first_name"].stringValue) + " " + (dic["last_name"].stringValue)
        cell.lbl_Message.text = "\(dic["last_message"].stringValue)"
        
        if dic["no_of_message"].numberValue == 0 {
            cell.messageNotify.isHidden = true
        } else {
            cell.messageNotify.isHidden = false
        }
        
        cell.lbl_TimeAgo.text = dic["date"].stringValue
        
        let imgLogoUrl = dic["image"].stringValue
        let urlwithPercentEscapes = imgLogoUrl.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        
        let urlLogo = URL(string: urlwithPercentEscapes!)
        cell.img_User.sd_setImage(with: urlLogo, placeholderImage: UIImage.init(named: "Profile_Pla"), options: SDWebImageOptions(rawValue: 1), completed: nil)
        return cell
    }
}

extension ChatConversationVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = arr_List[indexPath.row]
        kappDelegate.strBack = "menu"
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "UserChat") as! UserChat
        objVC.receiverId = dic["sender_id"].stringValue
        objVC.userName = (dic["first_name"].stringValue) + " " + (dic["last_name"].stringValue)
        objVC.strReasonID = dic["request_id"].stringValue
        self.navigationController?.pushViewController(objVC, animated: true)
    }
}
