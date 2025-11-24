//
//  UpcomingShiftCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 22/09/25.
//

import UIKit
import SwiftyJSON

class UpcomingShiftCell: UITableViewCell {

    @IBOutlet weak var lbl_Date: UILabel!
    @IBOutlet weak var ShiftTableVw: UITableView!
    @IBOutlet weak var shiftTableHeight: NSLayoutConstraint!
    
    var arrayShift:[JSON] = []
    var strDate:String = ""
    var navigationController: UINavigationController?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ShiftTableVw.delegate = self
        ShiftTableVw.dataSource = self
        self.ShiftTableVw.register(UINib(nibName: "SubShiftCell", bundle: nil), forCellReuseIdentifier: "SubShiftCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

extension UpcomingShiftCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayShift.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubShiftCell", for: indexPath) as! SubShiftCell
        let obj = arrayShift[indexPath.row]
        
        cell.lbl_JobName.text = obj["job_type"].stringValue
        cell.lbl_Time.text = "\(obj["start_time"].stringValue) : \(obj["end_time"].stringValue)"
//        cell.lbl_Note.text = "Note : \(obj["note"].stringValue)"
        
        if obj["break_type"].stringValue != "Not Applicable" {
            cell.lbl_BreakTime.text = "Break Time: \(obj["shift_break_time"].stringValue)"
        } else {
            cell.lbl_BreakTime.isHidden = true
        }
        
        cell.lbl_Break.text = "Break : \(obj["break_type"].stringValue)"
        cell.lbl_Meal.text = "Meals : \(obj["meals"].stringValue)"
        
        // Progress logic
        let workerCount = Int(obj["worker_count"].stringValue) ?? 0
        let bookedCount = Int(obj["booked_worker_count"].stringValue) ?? 0
        
        if workerCount > 0 {
            let ratio = Float(bookedCount) / Float(workerCount)
            
            cell.progressVw.progress = ratio
            cell.progressVw.trackTintColor = .separator // Remaining portion color
            
            if workerCount == bookedCount {
                cell.progressVw.progressTintColor = R.color.greeN() // Fully booked – green
                cell.lbl_AvailableSlot.text = "\(obj["booked_worker_count"].stringValue)/\(obj["worker_count"].stringValue) Fully Booked"

            } else {
                cell.progressVw.progressTintColor = R.color.button_COLOR() // Partially booked –
//                yellow
                cell.lbl_AvailableSlot.text = "\(obj["booked_worker_count"].stringValue)/\(obj["worker_count"].stringValue)  \(obj["remain_worker_count"].stringValue) slot available"

            }
        } else {
            cell.progressVw.progress = 0.0
            cell.progressVw.progressTintColor = .yellow
            cell.progressVw.trackTintColor = .separator
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "RequestByDateVC") as! RequestByDateVC
        objVC.strDate = strDate
        navigationController?.pushViewController(objVC, animated: true)
    }
}
