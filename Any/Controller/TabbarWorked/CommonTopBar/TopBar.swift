//
//  TopBar.swift
//  NG Rewards
//
//  Created by mac on 18/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class TopBar: UIView {
    
    @IBOutlet var lbl_Noti: UILabel!
    @IBOutlet var btn_Notification: UIButton!
    
    @IBOutlet weak var lbl_ChatCount: UILabel!
    @IBOutlet weak var btn_Chat: UIButton!
    @IBOutlet weak var btn_Menu: UIButton!
    @IBOutlet weak var menu_Vw: UIView!
    @IBOutlet weak var notification_Vw: UIView!
    @IBOutlet weak var chat_Vw: UIView!
    
    @IBOutlet weak var lbl_AttendanceRate: UILabel!
    @IBOutlet weak var lbl_Review: UILabel!
    @IBOutlet weak var btn_SeeAll: UIButton!
    @IBOutlet weak var attendanceVw: UIStackView!
    
    var isCount:Int! = 0
    var strReview:String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSpinningWheel), name: NSNotification.Name(rawValue: "badgeCount"), object: nil)
    }
    
    @objc func showSpinningWheel(notification: NSNotification) {
        print("sdsd \(notification.object)")

        if let request = notification.userInfo?["requestCount"] as? NSNumber {
            lbl_Noti.text = request != 0 ? "\(request)" : ""
            lbl_Noti.isHidden = (request == 0)
        }
        
        if let chatCount = notification.userInfo?["chatCount"] as? NSNumber {
            lbl_ChatCount.text = chatCount != 0 ? "\(chatCount)" : ""
            lbl_ChatCount.isHidden = (chatCount == 0)
        }
        
        // ✅ Attendance Rate (string)
        if let attendance = notification.userInfo?["attendanceRate"] as? String {
            lbl_AttendanceRate.text = "Your attendance rate: \(attendance)"
        }
        
        // ✅ Review (string)
        if let review = notification.userInfo?["review"] as? String {
            self.strReview = review
        }
        
        if let ratingCount = notification.userInfo?["ratingCount"] as? NSNumber {
            lbl_Review.text = "\(self.strReview) ( \(ratingCount) Reviews )"
        }
    }
    
//    @objc func showSpinningWheel(notification: NSNotification) {
//        
//        print("sdsd \(notification.object)")
//        
//        if let request = notification.userInfo?["requestCount"] as? NSNumber {
//            lbl_Noti.text = request != 0 ? "\(request)" : ""
//            lbl_Noti.isHidden = (request == 0)
//        }
//        
//        if let chatCount = notification.userInfo?["chatCount"] as? NSNumber {
//            lbl_ChatCount.text = chatCount != 0 ? "\(chatCount)" : ""
//            lbl_ChatCount.isHidden = (chatCount == 0)
//        }
//    }
}
