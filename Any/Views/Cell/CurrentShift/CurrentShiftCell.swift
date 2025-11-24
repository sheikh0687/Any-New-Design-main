//
//  CurrentShiftCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 15/01/25.
//

import UIKit

class CurrentShiftCell: UITableViewCell {

    @IBOutlet weak var lbl_StartEndTime: UILabel!
    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var lbl_Meal: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_AvailableDays: UILabel!
    
    @IBOutlet weak var btn_ThreeDot: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
