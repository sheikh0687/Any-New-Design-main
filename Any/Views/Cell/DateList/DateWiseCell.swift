//
//  DateWiseCell.swift
//  Any
//
//  Created by Techimmense Software Solutions on 17/02/24.
//

import UIKit
import SwiftyJSON

class DateWiseCell: UITableViewCell {
    
    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var collectionDates: UICollectionView!
    
    var navigationController: UINavigationController?
    
    var arr_DateWiseList:[JSON] = []
    var clo_BookTap:((_ buttonTag: UIButton) -> Void)?
    var clo_DidSelect:(() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionDates.register(UINib(nibName: "DateCollectionCell", bundle: nil), forCellWithReuseIdentifier: "DateCollectionCell")
        collectionDates.dataSource = self
        collectionDates.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension DateWiseCell: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr_DateWiseList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCollectionCell", for: indexPath) as! DateCollectionCell
        let dic = arr_DateWiseList[indexPath.row]
        cell.lbl_NumberCount.text = "\(dic["accept_shift_count"].numberValue)"
        cell.lbl_NumberCount.clipsToBounds = true
        cell.lbl_NumberCount.cornerRadius1 = 18

        cell.lbl_PendingCount.text = "\(dic["pending_shift_count"].numberValue)"
        cell.lbl_PendingCount.clipsToBounds = true
        cell.lbl_PendingCount.cornerRadius1 = 7

        
        if "\(dic["pending_shift_count"].numberValue)" == "0" && "\(dic["accept_shift_count"].numberValue)" == "0" {
            cell.lbl_NumberCount.isHidden = true
            cell.imgCloseBooking.isHidden = false
            
            if "\(dic["booking_status"].stringValue)" == "Open" {
                cell.lbl_NumberCount.isHidden = false
                cell.imgCloseBooking.isHidden = true
            }
            
        } else {
            cell.lbl_NumberCount.isHidden = false
            cell.imgCloseBooking.isHidden = true
        }
        
        if "\(dic["pending_shift_count"].numberValue)" == "0" {
            cell.lbl_PendingCount.isHidden = true
        } else {
            cell.lbl_PendingCount.isHidden = false
        }
        
        if "\(dic["booking_status"].stringValue)" == "Close" {
            cell.lbl_NumberCount.backgroundColor = R.color.greeN()
            cell.lbl_NumberCount.textColor = .white
        } else {
            cell.lbl_NumberCount.backgroundColor = .white
            cell.lbl_NumberCount.textColor = R.color.greeN()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/7, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "RequestByDateVC") as! RequestByDateVC
        let obj = self.arr_DateWiseList[indexPath.item]
        objVC.strDate = obj["week_date"].stringValue
        print(objVC.strDate)
        navigationController?.pushViewController(objVC, animated: true)
    }
}

