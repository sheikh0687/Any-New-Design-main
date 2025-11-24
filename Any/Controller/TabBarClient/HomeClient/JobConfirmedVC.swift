//
//  JobConfirmedVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 21/01/25.
//

import UIKit

class JobConfirmedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Success", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    override func leftClick() {
        Switcher.updateRootVC()
    }

    @IBAction func btn_backTODashboard(_ sender: UIButton) {
        Switcher.updateRootVC()
    }
    
    @IBAction func btn_ViewJobPost(_ sender: UIButton) {
        let vC = R.storyboard.main().instantiateViewController(withIdentifier: "CurrentShiftVC") as! CurrentShiftVC
        self.navigationController?.pushViewController(vC, animated: true)
    }
}
