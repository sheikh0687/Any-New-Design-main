//
//  SaveCardCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 18/04/24.
//

import UIKit

class SaveCardCell: UITableViewCell {

    @IBOutlet weak var lbl_Card: UILabel!
    
    var cloDelete:(() -> Void)?
    var cloChoose:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Delete(_ sender: UIButton) {
        self.cloDelete?()
    }
    
    @IBAction func btn_Choose(_ sender: UIButton) {
        self.cloChoose?()
    }
}
