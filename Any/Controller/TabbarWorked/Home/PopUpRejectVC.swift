//
//  PopUpRejectVC.swift
//  Any
//
//  Created by mac on 08/06/23.
//

import UIKit
import SwiftyJSON

class PopUpRejectVC: UIViewController {
    
    @IBOutlet weak var lbl_DEsc: UILabel!
    @IBOutlet weak var lbl_Head: UILabel!
    @IBOutlet weak var btn_two: UIButton!
   
    var strFrom:String! = ""

    var str_Head:String! = "Are you sure want to stop searching for part time workers?"
    var str_Desc:String! = "Accepted bookings will not be cancelled"
    var dicApp:JSON!
    var completion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_Head.text = str_Head
        lbl_DEsc.text = str_Desc
    }
    
    @IBAction func back(_ sender: Any) {
     
        self.dismiss(animated: false, completion: nil)


    }
    
    @IBAction func one(_ sender: Any) {

        self.dismiss(animated: false, completion: nil)

    }
    

}

