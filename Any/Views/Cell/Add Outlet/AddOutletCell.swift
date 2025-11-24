//
//  AddOutletCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 17/11/25.
//

import UIKit

class AddOutletCell: UITableViewCell {

    @IBOutlet weak var outletImg: UIImageView!
    
    @IBOutlet weak var lbl_OutletName: UILabel!
    @IBOutlet weak var lbl_OutletAddress: UILabel!
    
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
