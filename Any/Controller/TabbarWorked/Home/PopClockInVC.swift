//
//  PopClockInVC.swift
//  Any
//
//  Created by mac on 06/06/23.
//

import UIKit
import SwiftyJSON

protocol FooTwoViewControllerDelegate {
    func myVCDidFinish(text: String)
}

class PopClockInVC: UIViewController {
    
    @IBOutlet weak var lbl_DEsc: UILabel!
    @IBOutlet weak var lbl_Head: UILabel!
    @IBOutlet weak var btn_one: UIButton!
    @IBOutlet weak var btn_two: UIButton!
    @IBOutlet weak var lbl_Sub_DEsc: UILabel!
    
    var str_One:String! = ""
    var str_Two:String! = ""
    var strFrom:String! = ""
    var strStatus:String! = ""
    
    var str_Head:String! = ""
    var str_Desc:String! = ""
    var str_Sub_Desc:String! = ""
    var delegate: FooTwoViewControllerDelegate?
    
    var dicApp:JSON!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbl_Head.text = str_Head
        lbl_DEsc.text = str_Desc
        lbl_Sub_DEsc.text = str_Sub_Desc
        
        btn_one.setTitle(str_One, for: .normal)
        btn_two.setTitle(str_Two, for: .normal)
        
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @IBAction func one(_ sender: Any) {
        
        if strFrom == "Retry" {
            delegate?.myVCDidFinish(text: "Retry")
            self.dismiss(animated: false, completion: nil)
            
        } else if strFrom == "CheckOut" {
            delegate?.myVCDidFinish(text: "CheckOut")
            self.dismiss(animated: false, completion: nil)
            
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func two(_ sender: Any) {
        if strFrom == "Retry" {
            delegate?.myVCDidFinish(text: "Message")
            self.dismiss(animated: false, completion: nil)
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

