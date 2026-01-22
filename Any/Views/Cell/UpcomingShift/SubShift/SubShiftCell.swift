//
//  SubShiftCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 22/09/25.
//

import UIKit
import SwiftyJSON

class SubShiftCell: UITableViewCell {

    @IBOutlet weak var lbl_JobName: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_AvailableSlot: UILabel!
    @IBOutlet weak var progressVw: UIProgressView!
    
    @IBOutlet weak var lbl_BreakTime: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_Meal: UILabel!
    @IBOutlet weak var lbl_Note: UILabel!
    
    @IBOutlet weak var workerCollectionView: UICollectionView!
    
    var arrayWorker: [JSON] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.workerCollectionView.register(UINib(nibName: "WorkerDtCell", bundle: nil), forCellWithReuseIdentifier: "WorkerDtCell")
        workerCollectionView.dataSource = self
        workerCollectionView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension SubShiftCell: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrayWorker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WorkerDtCell", for: indexPath) as! WorkerDtCell
        let obj = self.arrayWorker[indexPath.row]
        
        cell.lbl_WorkerName.text = "\(obj["first_name"].stringValue)\n\(obj["last_name"].stringValue)"
        if Router.BASE_IMAGE_URL != obj["image"].stringValue {
            Utility.setImageWithSDWebImage(obj["image"].stringValue, cell.imgWorkers)
        } else {
            cell.imgWorkers.image = R.image.profile_Pla()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/3, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

