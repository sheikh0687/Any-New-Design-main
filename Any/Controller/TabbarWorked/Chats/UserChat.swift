

import UIKit
import SDWebImage
import SwiftyJSON

class UserChat: UIViewController {
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ShowRequest), name: Notification.Name("NewMessage"), object: nil)
        
        view_OldChat.isHidden = true
        vwMsg.isHidden = false
        
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: userName, CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
        Task {
           await wsGetChatAgain()
        }
    }
    
    @objc func ShowRequest (notification: NSNotification) {
       Task {
           await wsGetChatAgain()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func actionSend(_ sender: Any) {
        if tvMsg.text == "Write here..." || tvMsg.text.count == 0 {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: "Please enter message", on: self)
        } else {
           Task {
               await wsSendMessage()
            }
        }
    }
    
    //MARK: WS_SEND_MESSAGE
    func wsSendMessage() async {
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
        paramDict["sender_type"] = USER_DEFAULT.value(forKey: USER_TYPE) as AnyObject
        
        print(paramDict)
                
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.insert_chat.url(), parameters: paramDict, parentViewController: self)
            if(swiftyJsonVar["status"].stringValue == "1") {
                self.tvMsg.text = ""
                self.view.endEditing(true)
               Task {
                   await self.wsGetChatAgain()
                }
            }
        } catch {
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
        }
        
        hideProgressBar()
    }
    
    func wsGetChatAgain() async {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["receiver_id"]  =   userId as AnyObject
        paramDict["sender_id"]  =  receiverId  as AnyObject
        paramDict["request_id"]  =   strReasonID as AnyObject
        paramDict["type"]  =   "Normal" as AnyObject
        
        print(paramDict)

        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.get_chat_detail.url(), parameters: paramDict, parentViewController: self)
            if(swiftyJsonVar["status"].stringValue == "1") {
                self.arrMsgs  = swiftyJsonVar["result"].arrayValue
                self.tblView.reloadData()
                self.scrollToBottom()
                self.lbl_ChatReason.text = self.strReason
            }
            
        } catch {
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
        }
        
        self.hideProgressBar()
    }
}

//MARK: TABLEVIEW DELEGATE
extension UserChat: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMsgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.chatLeft.isHidden = true
        cell.chatRight.isHidden = true
        
        let dict = arrMsgs[indexPath.row]
        
        cell.lblDate.text = dict["date_time"].stringValue
        
        if dict["sender_id"].stringValue == userId {
            let strImage = dict["sender_detail"]["sender_image"].stringValue
            cell.imgRight.sd_setImage(with: URL.init(string: strImage), placeholderImage: UIImage.init(named: "Profile_Pla"), options: SDWebImageOptions(rawValue: 1), completed: nil)
            cell.chatRight.isHidden = false
            
            cell.lblMsgRight.text = dict["chat_message"].stringValue
            cell.lblDate.textAlignment = .right
            
            if dict["type"] == "Support" {
                if dict["admin_status"].stringValue == "SEEN" {
                    cell.lblSeenStatus.text = "Read"
                    cell.lblSeenStatus.textColor = .white
                } else {
                    cell.lblSeenStatus.text = "Sent"
                    cell.lblSeenStatus.textColor = .gray
                }
            } else {
                if dict["status"].stringValue == "SEEN" {
                    cell.lblSeenStatus.text = "Read"
                    cell.lblSeenStatus.textColor = .white
                } else {
                    cell.lblSeenStatus.text = "Sent"
                    cell.lblSeenStatus.textColor = .gray
                }
            }
        } else {
            let strImage = dict["sender_detail"]["sender_image"].stringValue
            cell.imgLeft.sd_setImage(with: URL.init(string: strImage), placeholderImage: UIImage.init(named: "Profile_Pla"), options: SDWebImageOptions(rawValue: 1), completed: nil)
            cell.chatLeft.isHidden = false
            cell.lblMsgLeft.text = dict["chat_message"].stringValue
            cell.lblDate.textAlignment = .left
            
            if dict["type"] == "Support" {
                cell.lblSupportName.isHidden = false
                cell.lblSupportName.text = dict["support_name"].stringValue
            } else {
                cell.lblSupportName.isHidden = true
            }
        }
        
        return cell
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.arrMsgs.count-1, section: 0)
            self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

//MARK: TEXTVIEW DELEGATE
extension UserChat: UITextViewDelegate {
    
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
