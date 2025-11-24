//
//  MultiDateCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 23/09/25.
//

import UIKit

class MultiDateCell: UICollectionViewCell {

    @IBOutlet weak var lbl_Date: UILabel!
    var cloCancel: () -> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func btn_Cancel(_ sender: Any) {
        self.cloCancel()
    }
}
