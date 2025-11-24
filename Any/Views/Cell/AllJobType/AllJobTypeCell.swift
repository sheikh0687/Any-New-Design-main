//
//  AllJobTypeCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 10/10/24.
//

import UIKit

class AllJobTypeCell: UITableViewCell {

    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var img_Selected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
