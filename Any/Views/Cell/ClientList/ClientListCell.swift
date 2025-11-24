//
//  ClientListCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 05/10/24.
//

import UIKit

class ClientListCell: UITableViewCell {

    @IBOutlet weak var clientLogo_Img: UIImageView!
    @IBOutlet weak var lbl_BusinessName: UILabel!
    @IBOutlet weak var lbl_AvailbaleStatus: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    @IBOutlet weak var lbl_InstantApproval: UILabel!
    @IBOutlet weak var btn_LikeOt: UIButton!
    
    var cloLike:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Like(_ sender: UIButton) {
        self.cloLike?()
    }
}
