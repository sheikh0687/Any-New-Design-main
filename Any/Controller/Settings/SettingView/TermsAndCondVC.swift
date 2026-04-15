

import UIKit
import WebKit
import SwiftyJSON

class TermsAndCondVC: UIViewController {
    
    @IBOutlet weak var lbl_About: UILabel!
    
    var strTitle:String! = ""
    var strDesc:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isHidden = false
        
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: strTitle, CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        self.view.addSubview(webView)
        
        let url = URL(string:  "https://www.anytimeanywork.com/terms")
        webView.load(URLRequest(url: url!))
        
    }
    
    func CheckEmailStatus() async {
        
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        do {
            let swiftyJsonVar = try await CommunicationManager.callPostServiceAsync(apiUrl: Router.get_user_page.url(), parameters: paramsDict,  parentViewController: self)
            if(swiftyJsonVar["status"] == "1") {
                let dicAll = swiftyJsonVar["result"]
                if kappDelegate.strTitle == "Terms and Conditions" {
                    strDesc = dicAll["term_sp"].stringValue
                    lbl_About.attributedText = strDesc.htmlToAttributedString
                } else {
                    strDesc = dicAll["privacy_sp"].stringValue
                    lbl_About.attributedText = strDesc.htmlToAttributedString
                }
            }
        } catch {
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        }
        
        hideProgressBar()
    }
}

extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
}
