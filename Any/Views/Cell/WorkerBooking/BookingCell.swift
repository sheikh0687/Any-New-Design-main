//
//  BookingCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 02/10/24.
//

import UIKit

class BookingCell: UITableViewCell {

    @IBOutlet weak var logo_Img: UIImageView!
    
    @IBOutlet weak var lbl_BusinessName: UILabel!
    @IBOutlet weak var lbl_DayAndDate: UILabel!
    @IBOutlet weak var lbl_HourRate: UILabel!
    @IBOutlet weak var lbl_ShiftTime: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    
    @IBOutlet weak var btn_ConfirmOt: UIButton!
    @IBOutlet weak var btn_SendMessageOt: UIButton!
    @IBOutlet weak var btn_Delete: UIButton!
    
    var cloConfirm:(() -> Void)?
    var cloMessage:(() -> Void)?
    var cloDelete:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Confirm(_ sender: UIButton) {
        self.cloConfirm?()
    }
    
    @IBAction func btn_SendMessage(_ sender: UIButton) {
        self.cloMessage?()
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        self.cloDelete?()
    }
}
