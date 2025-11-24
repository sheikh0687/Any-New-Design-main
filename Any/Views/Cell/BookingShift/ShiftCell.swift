//
//  ShiftCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 04/10/24.
//

import UIKit

class ShiftCell: UITableViewCell {

    @IBOutlet weak var lbl_ShiftTime: UILabel!
    @IBOutlet weak var lbl_Hour: UILabel!
    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_Meal: UILabel!
    @IBOutlet weak var lbl_Note: UILabel!
    
    @IBOutlet weak var lbl_Status: UILabel!
    @IBOutlet weak var lbl_BreakTime: UILabel!
    
    @IBOutlet weak var btn_BookOt: UIButton!
    @IBOutlet weak var btn_WithdrawOt: UIButton!
    @IBOutlet weak var btn_ClosedOt: UIButton!
    
    @IBOutlet weak var lbl_InstantApproval: UILabel!
    
    @IBOutlet weak var view_Bg: UIView!
    
    
    var cloBook:(() -> Void)?
    var cloWithdraw:(() -> Void)?
    var cloClosed:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func btn_Book(_ sender: UIButton) {
        self.cloBook?()
    }
    
    @IBAction func btn_Withdraw(_ sender: UIButton) {
        self.cloWithdraw?()
    }
    
    @IBAction func btn_Closed(_ sender: UIButton) {
        self.cloClosed?()
    }
}
