//
//  PopUpBookingConfirmVC.swift
//  Any
//
//  Created by mac on 14/06/23.
//

import UIKit
import SwiftyJSON

class PopUpBookingConfirmVC: UIViewController {
    
    @IBOutlet weak var lbl_DEsc: UILabel!
    @IBOutlet weak var lbl_Head: UILabel!
    @IBOutlet weak var btn_one: UIButton!
    @IBOutlet weak var btn_two: UIButton!
    @IBOutlet weak var lbl_Sub_DEsc: UILabel!
    @IBOutlet weak var lbl_Sub_DEsc2: UILabel!

    var str_One:String! = ""
    var str_Two:String! = ""
    var strFrom:String! = ""
    var strStatus:String! = ""

    var str_Head:String! = ""
    var str_Desc:String! = ""
    var str_Sub_Desc:String! = ""
    var str_Sub_Desc2:String! = ""

    var delegate: FooTwoViewControllerDelegate?

    var dicApp:JSON!

    override func viewDidLoad() {
        super.viewDidLoad()
      
        lbl_DEsc.text = str_Desc
        lbl_Sub_DEsc.text = str_Sub_Desc
        lbl_Sub_DEsc2.text = str_Sub_Desc2


    }
    
    @IBAction func back(_ sender: Any) {
        
        delegate?.myVCDidFinish(text: "Confirm")
        self.dismiss(animated: false, completion: nil)

    }
    
    @IBAction func one(_ sender: Any) {

        delegate?.myVCDidFinish(text: "Confirm")
        self.dismiss(animated: false, completion: nil)

    }
    
    @IBAction func two(_ sender: Any) {
        
        delegate?.myVCDidFinish(text: "Message")
        self.dismiss(animated: false, completion: nil)

    }
    

}
