//
//  WorkerShiftTimeCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 18/01/25.
//

import UIKit

class WorkerShiftTimeCell: UITableViewCell {

    @IBOutlet weak var lbl_WorkerCount: UILabel!
    @IBOutlet weak var btn_StartTimeOt: UIButton!
    @IBOutlet weak var btn_EndTimeOt: UIButton!
    
    var cloStartTime:(() -> Void)?
    var cloEndTime:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_StartTime(_ sender: UIButton) {
        self.cloStartTime?()
    }
    
    @IBAction func btn_EndTime(_ sender: UIButton) {
        self.cloEndTime?()
    }
}
