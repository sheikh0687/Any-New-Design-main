//
//  PopUpSimpleVC.swift
//  Any
//
//  Created by mac on 31/05/23.
//

import UIKit

class PopUpSimpleVC: UIViewController {
    
    @IBOutlet weak var lbl_DEsc: UILabel!
    @IBOutlet weak var lbl_Head: UILabel!
    @IBOutlet weak var lbl_DEsc2: UILabel!

    var completion: (() -> Void)?

    var str_Head:String! = ""
    var str_Desc:String! = ""
    var str_Desc1:String! = ""

    var is_Navigate:String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbl_Head.text = str_Head
        lbl_DEsc.text = str_Desc
        lbl_DEsc2.text = str_Desc1
    }
    
    @IBAction func back(_ sender: Any) {
        if let completion = completion {
          completion()
        }
        if is_Navigate == "Monthly" || is_Navigate == "CustomerAndCard" {
            self.dismiss(animated: false, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
