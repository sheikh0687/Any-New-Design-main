//
//  ReferFriendVC.swift
//  Any
//
//  Created by mac on 18/05/23.
//

import UIKit

class ReferFriendVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {

        self.navigationController?.navigationBar.isHidden = false
    
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Refer Friends", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
     
    }


    @IBAction func invitee(_ sender: Any) {
        if Utility.isUserLogin() {
            let shareText = "Please install Anytime Work app from app store  https://apps.apple.com/us/app/anytime-work/id1576680333"
            let shareItems: [Any] = [shareText]
            
            let activityVC = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityVC.excludedActivityTypes = [.airDrop, .postToFlickr, .assignToContact, .openInIBooks]
            
            self.present(activityVC, animated: true, completion: nil)

        } else {
            self.alert(alertmessage: "Please create an account to use this feature.")
        }
    }
}
