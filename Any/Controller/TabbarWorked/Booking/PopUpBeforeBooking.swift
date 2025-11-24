//
//  PopUpBookinConfirmVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 23/01/25.
//

import UIKit

class PopUpBeforeBooking: UIViewController {

    @IBOutlet weak var lbl_Heading: UILabel!
    @IBOutlet weak var lbl_BookingName: UILabel!
    @IBOutlet weak var lbl_BookingDetail: UILabel!
    @IBOutlet weak var lbl_BookingNote: UILabel!
    @IBOutlet weak var lbl_Suspension: UILabel!
    
    @IBOutlet weak var lbl_InstantApproval: UILabel!

    @IBOutlet weak var btn_ProceedOt: UIButton!
    @IBOutlet weak var btn_ReturnOt: UIButton!
    
    var cloBook:(() -> Void)?
    
    var isFrom:String = ""
    
    var isPendingBooking:String = ""
    
    var strBookinName:String = ""
    var strBookingDetail:String = ""
    var strBookingNote:String = ""
    var strHeadline:String = ""
    var strInstantApproval:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFrom == "Book" {
            self.lbl_Heading.text = "Are you sure for booking?"
            self.lbl_BookingName.text = strBookinName
            self.lbl_BookingName.textColor = R.color.theme_COLOR()
            self.lbl_BookingDetail.text = self.strBookingDetail
            self.lbl_BookingNote.text = self.strBookingNote
            self.lbl_Suspension.isHidden = true
            self.btn_ProceedOt.setTitle("Book", for: .normal)
            self.btn_ReturnOt.setTitle("Return", for: .normal)
            if strInstantApproval == "Yes" {
                self.lbl_InstantApproval.isHidden = false
            } else {
                self.lbl_InstantApproval.isHidden = true
            }
        } else {
            self.lbl_InstantApproval.isHidden = true
            self.lbl_Heading.text = "Are you sure you want to cancel your for booking?"
            self.lbl_BookingName.text = strBookinName
            self.lbl_BookingName.textColor = .darkGray
            self.lbl_BookingDetail.text = "Any confirmed bookings will have $10 cancellation penalty fee to be deducted on your next shifts payment."
            self.lbl_BookingNote.text = "Any shift cancelled within 48 hours of work start with is considered last minute."
            self.lbl_Suspension.isHidden = false
            self.lbl_Suspension.text = "Account suspension for 1 month if you have cancelled last minute twice in a month."
            self.btn_ProceedOt.titleLabel?.numberOfLines = 2
            self.btn_ProceedOt.titleLabel?.textAlignment = .center
            self.btn_ProceedOt.titleLabel?.lineBreakMode = .byWordWrapping
            self.btn_ProceedOt.titleLabel?.font = UIFont.systemFont(ofSize: 11) // Adjust font size as needed
            if isPendingBooking == "Accept" {
                self.btn_ProceedOt.setTitle("WhatsApp\n+6582231930 To Cancel", for: .normal)
            } else {
                self.btn_ProceedOt.setTitle("Yes, Proceed", for: .normal)
            }
        }
    }
    
    @IBAction func btn_Book(_ sender: UIButton) {
        if isFrom == "Book" {
            self.cloBook?()
            self.dismiss(animated: true)
        } else {
            if isPendingBooking == "Accept" {
                self.dismiss(animated: true)
            } else {
                self.cloBook?()
                self.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func btn_Return(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btn_Cancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
