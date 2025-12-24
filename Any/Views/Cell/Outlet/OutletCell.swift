//
//  OutletCell.swift
//  Any
//
//  Created by Arbaz  on 28/11/25.
//

import UIKit
import DropDown

class OutletCell: DropDownCell {

    @IBOutlet weak var outletImg: UIImageView!
    @IBOutlet weak var lbl_OutletName: UILabel!
    @IBOutlet weak var lbl_OutletCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
