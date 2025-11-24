//
//  JobRequestCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 10/10/24.
//

import UIKit

class JobRequestCell: UITableViewCell {

    @IBOutlet weak var lbl_JobType: UILabel!
    @IBOutlet weak var lbl_JobDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
