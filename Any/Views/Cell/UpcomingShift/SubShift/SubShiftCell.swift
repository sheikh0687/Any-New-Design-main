//
//  SubShiftCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 22/09/25.
//

import UIKit

class SubShiftCell: UITableViewCell {

    @IBOutlet weak var lbl_JobName: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_AvailableSlot: UILabel!
    @IBOutlet weak var progressVw: UIProgressView!
    
    @IBOutlet weak var lbl_BreakTime: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_Meal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

