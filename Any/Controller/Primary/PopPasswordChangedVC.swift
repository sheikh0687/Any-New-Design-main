//
//  PopPasswordChangedVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 04/02/25.
//

import UIKit

class PopPasswordChangedVC: UIViewController {

    var cloSuccess: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func btn_Cancel(_ sender: UIButton) {
        Switcher.updateRootVC()
    }
    
    @IBAction func btn_Login(_ sender: UIButton) {
        self.cloSuccess?()
        self.dismiss(animated: true)
    }
}
