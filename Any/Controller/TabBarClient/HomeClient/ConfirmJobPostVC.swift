//
//  ConfirmJobPostVC.swift
//  Any
//
//  Created by Techimmense Software Solutions on 14/10/24.
//

import UIKit
import SwiftyJSON

class ConfirmJobPostVC: UIViewController {
    
    @IBOutlet weak var worker_TableVw: UITableView!
    var strJobiD:String = ""
    
    var array_WorkerList: [JSON] = []
    var arrayOfPreviousWorker:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.worker_TableVw.register(UINib(nibName: "PreviousWorkerCell", bundle: nil), forCellReuseIdentifier: "PreviousWorkerCell")
        WebGetPreviousWorker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Publish Job Post", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
    }
    
    @IBAction func btn_Yes(_ sender: UIButton) {
        
    }
    
    @IBAction func btn_SkipPublish(_ sender: UIButton) {
        webSubmit()
    }
}

extension ConfirmJobPostVC {
    
    func WebGetPreviousWorker()
    {
        var paramDict: [String : AnyObject] = [:]
        paramDict["client_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject?
        paramDict["job_type_id"] = strJobiD as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_worker_list_by_jobtype.url(), parameters: paramDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"] == "1") {
                    print("Fetched Successfully")
                    self.array_WorkerList = swiftyJsonVar["result"].arrayValue
                    print(self.array_WorkerList.count)
                    self.worker_TableVw.backgroundView = UIView()
                    self.worker_TableVw.reloadData()
                } else {
                    self.array_WorkerList = []
                    self.worker_TableVw.backgroundView = UIView()
                    self.worker_TableVw.reloadData()
                    Utility.noDataFound("No Workers At The Moment", tableViewOt: self.worker_TableVw, parentViewController: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func webSubmit()
    {
        paramJobPostDict["previous_worker_id"] = arrayOfPreviousWorker.joined(separator: ",") as AnyObject
        
        print(paramJobPostDict)
        
        CommunicationManager.callPostService(apiUrl: Router.set_shift.url(), parameters: paramJobPostDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"] == "1") {
                    let vC = R.storyboard.main.jobConfirmedVC()!
                    self.navigationController?.pushViewController(vC, animated: true)
                } else {
                    let message = swiftyJsonVar["message"].stringValue
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message, on: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            //            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
            let vC = R.storyboard.main.jobConfirmedVC()!
            self.navigationController?.pushViewController(vC, animated: true)
            
        })
    }
}

extension ConfirmJobPostVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array_WorkerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreviousWorkerCell", for: indexPath) as! PreviousWorkerCell
        let obj = self.array_WorkerList[indexPath.row]
        
        cell.lbl_WorkerName.text = "\(obj["first_name"].stringValue) \(obj["last_name"].stringValue)"
        cell.lbl_JobType.text = obj["job_type_name"].stringValue
        
        if Router.BASE_IMAGE_URL != obj["image"].stringValue {
            Utility.setImageWithSDWebImage(obj["image"].stringValue, cell.profile_Img)
        } else {
            cell.profile_Img.image = R.image.profile_ic()
        }
        
        if self.arrayOfPreviousWorker.contains(obj["id"].stringValue) {
            cell.img_Check.image = R.image.blueCirclecheck()
        } else {
            cell.img_Check.image = R.image.circleUncheck()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = self.array_WorkerList[indexPath.row]
        if arrayOfPreviousWorker.contains(obj["id"].stringValue) {
            arrayOfPreviousWorker.removeAll(where: {$0 == obj["id"].stringValue})
        } else {
            arrayOfPreviousWorker.append(obj["id"].stringValue)
        }
        worker_TableVw.reloadData()
    }
}
    
