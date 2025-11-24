//
//  PreviousWorkerCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 14/10/24.
//

import UIKit

class PreviousWorkerCell: UITableViewCell {

    @IBOutlet weak var profile_Img: UIImageView!
    @IBOutlet weak var lbl_WorkerName: UILabel!
    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var img_Check: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
