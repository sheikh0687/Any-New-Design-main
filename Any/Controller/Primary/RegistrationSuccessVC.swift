//
//  RegistrationSuccessVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 16/10/24.
//

import UIKit

class RegistrationSuccessVC: UIViewController {

    @IBOutlet weak var businessImg: UIImageView!
    @IBOutlet weak var lbl_BusinessName: UILabel!
    
    var imageBuisnesslogo:UIImage? = nil
    var strBusinessName:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.businessImg.image = imageBuisnesslogo
        self.lbl_BusinessName.text = strBusinessName
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Register Complete", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: WHITE_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_GoToDashboard(_ sender: UIButton) {
        Switcher.updateRootVC()
    }
}
