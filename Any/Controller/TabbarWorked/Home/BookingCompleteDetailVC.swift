//
//  BookingCompleteDetailVC.swift
//  Any
//
//  Created by mac on 25/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage

class BookingCompleteDetailVC: UIViewController {
    
    @IBOutlet weak var lbl_Note: UILabel!
    @IBOutlet weak var lbl_OutANswer: UILabel!
    @IBOutlet weak var lbl_BreakAnswer: UILabel!
    @IBOutlet weak var lbl_InAnswer: UILabel!
    @IBOutlet weak var lbl_Out: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_In: UILabel!
    
    @IBOutlet weak var lbl_TotalCost: UILabel!
    @IBOutlet weak var lbl_Rate: UILabel!
    @IBOutlet weak var lbl_TotalAnser: UILabel!
    @IBOutlet weak var lbl_Totall: UILabel!
    
    var dicClinetDetail:JSON!
    var dicCartDetail:JSON!

    var arr_List:[JSON] = []
    var arr_Break:[String] = ["No\nBreak","Take 30 minutes \nBreak","Take 1 Hours \nBreak"]

    var strDate:String! = ""
    var strlat:String! = ""
    var strlon:String! = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Booking Detail", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
        lbl_In.text = dicCartDetail["set_shift"]["start_time"].stringValue
        lbl_Out.text = dicCartDetail["set_shift"]["end_time"].stringValue
        lbl_Break.text = dicCartDetail["set_shift"]["break_type"].stringValue

        lbl_InAnswer.text = dicClinetDetail["clock_in_time"].stringValue
        lbl_OutANswer.text = dicClinetDetail["clock_out_time"].stringValue
        lbl_BreakAnswer.text = dicClinetDetail["break_time"].stringValue

        lbl_Totall.text = dicCartDetail["set_shift"]["total_time"].stringValue
        lbl_TotalAnser.text = dicClinetDetail["total_working_hr_time"].stringValue
        lbl_TotalCost.text = "\(USER_DEFAULT.value(forKey: CURRENCY_SYMBOL) ?? "")\(dicClinetDetail["total_amount"].stringValue)"
        lbl_Rate.text = "\(USER_DEFAULT.value(forKey: CURRENCY_SYMBOL) ?? "")\(dicClinetDetail["shift_rate"].stringValue)"
    }
    
    @IBAction func book(_ sender: Any) {
        Switcher.updateRootVC()
    }
}
