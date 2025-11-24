

import UIKit
import SDWebImage
import SwiftyJSON

class UserChat: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var view_OldChat: UIView!
    @IBOutlet weak var lbl_ChatReason: UILabel!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var vwMsg: UIView!
    @IBOutlet weak var tvMsg: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    
    var arrMsgs:[JSON] = []
    var receiverId = ""
    var userName = ""
    var userId = ""
    var strReason = ""
    var strReasonID = ""
    let strType = ""
    var strRighTitle = ""
    var strOldChat = ""
    var strGroup = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tvMsg.textColor = UIColor.darkGray
        tvMsg.text = "Write here..."
        
        print(userName)
        print(receiverId)
        
        userId = kUserDefault.value(forKey: USERID) as! String
        
        wsGetChatAgain()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShowRequest), name: Notification.Name("NewMessage"), object: nil)
        
        view_OldChat.isHidden = true
        vwMsg.isHidden = false
        
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: userName, CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @objc func ShowRequest (notification:NSNotification) {
        wsGetChatAgain()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionSend(_ sender: Any) {
        if tvMsg.text == "Write here..." || tvMsg.text.count == 0 {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: "Please enter message", on: self)
        } else {
            wsSendMessage()
        }
    }
    
    //MARK: TABLEVIEW DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMsgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.chatLeft.isHidden = true
        cell.chatRight.isHidden = true
        
        let dict = arrMsgs[indexPath.row]
        let strDate = dict["date"].stringValue
        
        if strDate != "0000-00-00 00:00:00" {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatter.date(from: strDate)
            formatter.dateFormat = "dd MMM yyyy hh:mm a"
            cell.lblDate.text = formatter.string(from: date ?? Date())
        } else {
            cell.lblDate.text = ""
        }
        
        if dict["sender_id"].stringValue == userId {
            let strImage = dict["sender_detail"]["sender_image"].stringValue
            cell.imgRight.sd_setImage(with: URL.init(string: strImage), placeholderImage: UIImage.init(named: "Profile_Pla"), options: SDWebImageOptions(rawValue: 1), completed: nil)
            cell.chatRight.isHidden = false
            cell.lblMsgRight.text = dict["chat_message"].stringValue
            cell.lblDate.textAlignment = .right
        } else {
            let strImage = dict["sender_detail"]["sender_image"].stringValue
            cell.imgLeft.sd_setImage(with: URL.init(string: strImage), placeholderImage: UIImage.init(named: "Profile_Pla"), options: SDWebImageOptions(rawValue: 1), completed: nil)
            cell.chatLeft.isHidden = false
            cell.lblMsgLeft.text = dict["chat_message"].stringValue
            cell.lblDate.textAlignment = .left
        }
        return cell
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.arrMsgs.count-1, section: 0)
            self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    //MARK: TEXTVIEW DELEGATE
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == tvMsg {
            if tvMsg.textColor == UIColor.darkGray {
                tvMsg.textColor = UIColor.black
                tvMsg.text = ""
            }
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == tvMsg {
            if tvMsg.text.count == 0 {
                tvMsg.textColor = UIColor.darkGray
                tvMsg.text = "Write here..."
            }
        }
    }
    
    //MARK: WS_SEND_MESSAGE
    
    func wsSendMessage()  {
        showProgressBar()
        var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
        
        var paramDict : [String:AnyObject] = [:]
        
        paramDict["receiver_id"]   =  receiverId as AnyObject
        paramDict["sender_id"]    =   userId as AnyObject
        paramDict["chat_message"]  =  tvMsg.text?.trimmingCharacters(in: .whitespacesAndNewlines) as AnyObject
        paramDict["timezone"]  =  localTimeZoneIdentifier as AnyObject
        paramDict["type"]  =   "Normal" as AnyObject
        paramDict["request_id"]  =   strReasonID as AnyObject
        paramDict["date_time"]  =   Date() as AnyObject
        
        print(paramDict)
        CommunicationManager.callPostService(apiUrl: Router.insert_chat.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.tvMsg.text = ""
                    self.view.endEditing(true)
                    self.wsGetChatAgain()
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func wsGetChatAgain()  {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["receiver_id"]  =   userId as AnyObject
        paramDict["sender_id"]  =  receiverId  as AnyObject
        paramDict["request_id"]  =   strReasonID as AnyObject
        paramDict["type"]  =   "Normal" as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_chat_detail.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrMsgs  = swiftyJsonVar["result"].arrayValue
                    self.tblView.reloadData()
                    self.scrollToBottom()
                    self.lbl_ChatReason.text = self.strReason
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
extension String {
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                0x1F680...0x1F6FF, // Transport and Map
                0x2600...0x26FF,   // Misc symbols
                0x2700...0x27BF,   // Dingbats
                0xFE00...0xFE0F,   // Variation Selectors
                0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
    
}
