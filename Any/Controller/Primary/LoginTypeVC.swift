

import UIKit

class LoginTypeVC: UIViewController {
    
    @IBOutlet weak var btn_JobOt: UIButton!
    @IBOutlet weak var btn_WorkerOt: UIButton!
    @IBOutlet weak var job_Img: UIImageView!
    @IBOutlet weak var btn_LookinFor: UIButton!
    @IBOutlet weak var lbl_TextOnImg: UILabel!
    
    var strType: String = "Worker"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btn_JobOt.setTitleColor(.white, for: .normal)
        btn_WorkerOt.setTitleColor(.darkGray, for: .normal)
        btn_JobOt.backgroundColor = UIColor(named: THEME_COLOR_NAME)
        btn_WorkerOt.backgroundColor = .systemGray6
        job_Img.image = UIImage(named: "Workers")
        self.btn_LookinFor.setTitle("I'm looking for jobs", for: .normal)
        self.lbl_TextOnImg.text = "I'm looking for jobs"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
   
    @IBAction func backk(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Worker(_ sender: Any) {
        strType = "Worker"
        btn_JobOt.setTitleColor(.white, for: .normal)
        btn_WorkerOt.setTitleColor(.darkGray, for: .normal)
        btn_JobOt.backgroundColor = UIColor(named: THEME_COLOR_NAME)
        btn_WorkerOt.backgroundColor = .systemGray6
        job_Img.image = UIImage(named: "Workers")
        self.lbl_TextOnImg.text = "I'm looking for jobs"
        self.btn_LookinFor.setTitle("I'm looking for jobs", for: .normal)
    }
    
    @IBAction func btn_Client(_ sender: Any) {
        strType = "Client"
        btn_WorkerOt.setTitleColor(.white, for: .normal)
        btn_JobOt.setTitleColor(.darkGray, for: .normal)
        btn_WorkerOt.backgroundColor = UIColor(named: THEME_COLOR_NAME)
        btn_JobOt.backgroundColor = .systemGray6
        job_Img.image = UIImage(named: "Employers")
        self.lbl_TextOnImg.text = "I'm looking for workers"
        self.btn_LookinFor.setTitle("I'm looking for workers", for: .normal)
    }
    
    @IBAction func btn_WhichJobSelected(_ sender: UIButton) {
        let vC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        vC.strType = strType
        print(strType)
        self.navigationController?.pushViewController(vC, animated: true)
    }
}
