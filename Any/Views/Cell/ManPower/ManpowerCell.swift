//
//  ManpowerCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 09/10/24.
//

import UIKit

class ManpowerCell: UITableViewCell {

    @IBOutlet weak var worker_Img: UIImageView!
    
    @IBOutlet weak var lbl_WorkerName: UILabel!
    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var lbl_StartEndTime: UILabel!
    @IBOutlet weak var lbl_HourlyRate: UILabel!
    @IBOutlet weak var lbl_Status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
