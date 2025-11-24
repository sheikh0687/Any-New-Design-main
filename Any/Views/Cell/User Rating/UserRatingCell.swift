//
//  UserRatingCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 08/10/25.
//

import UIKit
import Cosmos

class UserRatingCell: UITableViewCell {

    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var ratingStar: CosmosView!
    @IBOutlet weak var lblFeedback: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var clientImg: UIImageView!
    
    
//    @IBOutlet weak var lbl_Name: UILabel!
//    @IBOutlet weak var lblAddress: UILabel!
//    @IBOutlet weak var clientImg: UIImageView!
//    @IBOutlet weak var ratingStar: CosmosView!
//    @IBOutlet weak var lblFeedback: UILabel!
//    @IBOutlet weak var lblDateTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
