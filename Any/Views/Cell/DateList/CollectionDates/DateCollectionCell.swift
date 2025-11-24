//
//  DateCollectionCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 17/02/24.
//

import UIKit

class DateCollectionCell: UICollectionViewCell {

//    @IBOutlet weak var btn_Book: UIButton!
//    @IBOutlet weak var lbl_Two: UILabel!
//    @IBOutlet weak var lbl_One: UILabel!
    @IBOutlet weak var lbl_NumberCount: UILabel!
    @IBOutlet weak var lbl_PendingCount: UILabel!
    @IBOutlet weak var imgCloseBooking: UIImageView!
    
    var clo_Book:((_ tagg: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    @IBAction func btn_Book(_ sender: UIButton) {
//        self.clo_Book?(sender)
//    }
}
