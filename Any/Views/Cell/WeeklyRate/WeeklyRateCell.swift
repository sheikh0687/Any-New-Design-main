//
//  WeeklyRateCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 13/01/25.
//

import UIKit

class WeeklyRateCell: UICollectionViewCell {

    @IBOutlet weak var lbl_DayName: UILabel!
    @IBOutlet weak var lbl_Rate: UILabel!
    @IBOutlet weak var btn_DeleteOt: UIButton!
    @IBOutlet weak var btn_Plus: UIButton!
    @IBOutlet weak var btn_Minus: UIButton!
    
    var cloPlus:(() -> Void)?
    var cloMinus:(() -> Void)?
    var cloDelete:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btn_PlusButton(_ sender: UIButton) {
        self.cloPlus?()
    }
    
    @IBAction func btn_MinusButton(_ sender: UIButton) {
        self.cloMinus?()
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        self.cloDelete?()
    }
}
