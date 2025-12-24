//
//  BookingDetailVC.swift
//  Any
//
//  Created by mac on 25/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import CoreLocation

class BookingDetailVC: UIViewController, FooTwoViewControllerDelegate {
    
    @IBOutlet weak var lbl_Note: UILabel!
    @IBOutlet weak var lbl_OutANswer: UILabel!
    @IBOutlet weak var lbl_BreakAnswer: UILabel!
    @IBOutlet weak var lbl_Description: UILabel!
    @IBOutlet weak var lbl_InAnswer: UILabel!
    @IBOutlet weak var lbl_Out: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_In: UILabel!
    @IBOutlet weak var btnSeeSumm: UIButton!
    @IBOutlet weak var height_Coll: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewShift: UICollectionView!
    
    var dicRequestDetail:JSON!
    
    var arr_List:[JSON] = []
    var arr_Break:[String] = []
    
    var strCartId:String! = ""
    var strlat:String! = ""
    var strlon:String! = ""
    
    var workerLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WebGetBookingDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "back", CenterTitle: "Details", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        getWorkerCurrentLocation()
    }
    
    func getWorkerCurrentLocation()
    {
        AccurateLocationManager.shared.requestAccurateLocation { workerLocation in

            guard let workerLocation = workerLocation else {
                GlobalConstant.showAlertMessage(
                    withOkButtonAndTitle: "Location Error",
                    andMessage: "Unable to fetch your current location. Please enable GPS.",
                    on: self
                )
                return
            }

            self.workerLocation = workerLocation
            
            print("📍 Worker Current Location Updated: \(workerLocation.coordinate)")
        }
    }
    
    @IBAction func book(_ sender: Any) {
        checkWorkerDistanceFromClient { isNear in
            guard isNear else { return }
            
            if self.dicRequestDetail["working_status"].stringValue == "Pending" {
                self.WebAddClockIn(strType: "IN")
            } else {
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopClockInVC") as! PopClockInVC
                objVC.str_Head = "Check-out"
                objVC.str_Desc = "Proceed to check-out?"
                objVC.str_Sub_Desc = ""
                objVC.delegate = self
                objVC.str_One = "Yes, proceed"
                objVC.str_Two = "Back"
                objVC.strFrom = "CheckOut"
                objVC.modalPresentationStyle = .overCurrentContext
                objVC.modalTransitionStyle = .crossDissolve
                self.present(objVC, animated: false, completion: nil)
            }
        }
    }
    
    @IBAction func SeeSummary(_ sender: Any) {
        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "UserChat") as! UserChat
        objVC.receiverId = dicRequestDetail["client_details"]["id"].stringValue
        objVC.userName = (dicRequestDetail["client_details"]["first_name"].stringValue) + " " + (dicRequestDetail["client_details"]["last_name"].stringValue)
        objVC.strReasonID = dicRequestDetail["client_details"]["id"].stringValue
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    func myVCDidFinish(text: String) {
        if text == "Message" {
            let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "UserChat") as! UserChat
            objVC.receiverId = dicRequestDetail["client_details"]["id"].stringValue
            objVC.userName = (dicRequestDetail["client_details"]["first_name"].stringValue) + " " + (dicRequestDetail["client_details"]["last_name"].stringValue)
            objVC.strReasonID = dicRequestDetail["client_details"]["id"].stringValue
            self.navigationController?.pushViewController(objVC, animated: true)
            
        } else if text == "Retry"  {
            
            WebAddClockIn(strType: "IN")
            
        } else if text == "CheckOut"  {
            
            WebAddClockIn(strType: "OUT")
            
        } else {
            WebGetBookingDetail()
        }
    }
    
    func checkWorkerDistanceFromClient(completion: @escaping (Bool) -> Void) {
        
        guard let workerLocation = self.workerLocation else {
            GlobalConstant.showAlertMessage(
                withOkButtonAndTitle: "Location Missing",
                andMessage: "Still fetching your GPS location. Please wait a moment.",
                on: self
            )
            completion(false)
            return
        }

        print("📍 Worker Location:", workerLocation.coordinate)
        
        guard let clientLat = Double(self.strlat),
              let clientLon = Double(self.strlon) else {
            completion(false)
            return
        }

        let clientLocation = CLLocation(latitude: clientLat, longitude: clientLon)
        let distance = workerLocation.distance(from: clientLocation)

        print("🛰 Accurate Distance to client: \(distance) meters")

        if distance <= 150 {
            completion(true)
        } else {
            let status = self.dicRequestDetail["working_status"].stringValue
            let action = (status == "Pending") ? "clock-in" : "clock-out"

            GlobalConstant.showAlertMessage(
                withOkButtonAndTitle: "Too Far",
                andMessage: "Unable to \(action). You are outside the allowed location radius. Enable location services if they are off, then try again.",
                on: self
            )

            completion(false)
        }
    }
    
    //MARK: API
    
    func WebAddClockIn(strType:String) {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["cart_id"]  =   strCartId as AnyObject
        paramsDict["shift_id"]  =   dicRequestDetail["shift_id"].stringValue as AnyObject
        paramsDict["clock_time"]  =    Utility.getCurrentTime24HOur() as AnyObject
        paramsDict["type"]  =   strType as AnyObject
        paramsDict["date"]  =   Utility.getCurrentShortDateNew() as AnyObject
        paramsDict["lat"] = kappDelegate.CURRENT_LAT as AnyObject
        paramsDict["lon"] = kappDelegate.CURRENT_LON as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.add_clock_in_time.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                
                print(swiftyJsonVar)
                
                if(swiftyJsonVar["status"].stringValue == "1") {
                    if swiftyJsonVar["result"]["working_status"].stringValue == "Clock-Out" {
                        let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "BookingCompleteDetailVC") as! BookingCompleteDetailVC
                        objVC.dicCartDetail = dicRequestDetail
                        objVC.dicClinetDetail = swiftyJsonVar["result"]
                        self.navigationController?.pushViewController(objVC, animated: true)
                    } else if swiftyJsonVar["result"]["working_status"].stringValue == "Clock-In" {
                        self.navigationController?.popViewController(animated: true)
                    } else  {
                        WebGetBookingDetail()
                    }
                } else {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopClockInVC") as! PopClockInVC
                    objVC.str_Head = "Clock-in Unsuccessful"
                    objVC.str_Desc = swiftyJsonVar["message"].stringValue
                    objVC.str_Sub_Desc = dicRequestDetail["address"].stringValue
                    objVC.delegate = self
                    objVC.str_One = "Retry, Clock-in"
                    objVC.str_Two = "Message"
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
                }
                self.hideProgressBar()
                
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func WebGetBookingDetail() {
        
        showProgressBar()
        
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["cart_id"]  =   strCartId as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_set_shift_cart_details.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                
                if(swiftyJsonVar["status"].stringValue == "1") {
                    
                    dicRequestDetail = swiftyJsonVar["result"]
                    getDataShiftAvailble()
                    
                } else {}
                
                self.hideProgressBar()
                
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
        
    }
    
    func getDataShiftAvailble() {
        
        let dicShift = dicRequestDetail["set_shift"]
        print(dicShift)
        lbl_In.text = dicShift["start_time"].stringValue
        lbl_Out.text = dicShift["end_time"].stringValue
        lbl_Break.text = dicShift["break_type"].stringValue
        lbl_Description.text = dicShift["job_type"].stringValue
        
        lbl_InAnswer.text = dicRequestDetail["clock_in_time"].stringValue
        lbl_OutANswer.text = dicRequestDetail["clock_out_time"].stringValue
        lbl_BreakAnswer.text = dicRequestDetail["break_time"].stringValue
        strlat = dicRequestDetail["client_details"]["lat"].stringValue
        strlon = dicRequestDetail["client_details"]["lon"].stringValue
        print(lbl_Description.text ?? "")
        
        if dicRequestDetail["working_status"].stringValue == "Pending" {
            btnSeeSumm.setTitle("Clock-In", for: .normal)
            collectionViewShift.isHidden = true
        } else {
            if dicRequestDetail["set_shift"]["break_type"].stringValue == "Not Aplicable" {
                collectionViewShift.isHidden = true
            } else {
                collectionViewShift.isHidden = false
            }
            btnSeeSumm.setTitle("Check-out", for: .normal)
            
            if dicRequestDetail["set_shift"]["break_type"].stringValue == "Not Applicable" {
                collectionViewShift.isHidden = true
            } else {
                collectionViewShift.isHidden = false
            }
            btnSeeSumm.setTitle("Check-out", for: .normal)
        }
        
        if dicShift["shift_break_time"].stringValue == "" {
            arr_Break = ["No\nBreak","Take 30 minutes \nBreak","Take 1 Hours \nBreak"]
        } else {
            arr_Break = [dicShift["shift_break_time"].stringValue]
        }
        
        collectionViewShift.reloadData()
    }
    
}

extension BookingDetailVC: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arr_Break.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BookingShiftCell
        
        let dic = self.arr_Break[indexPath.row]
        
        if dicRequestDetail["shift_break_time"].stringValue != "" {
            cell.lbl_Break.text = dic
        } else {
            cell.lbl_Break.text = "\(dic)\n Break Time"
        }
        
        if dicRequestDetail["break_time"].stringValue == "30 min" && indexPath.row == 1 {
            cell.lbl_Break.backgroundColor = UIColor.init(named: THEME_COLOR_NAME)
            
        } else if dicRequestDetail["break_time"].stringValue == "No Break Taken" && indexPath.row == 0 {
            cell.lbl_Break.backgroundColor = UIColor.init(named: THEME_COLOR_NAME)
            
        } else if dicRequestDetail["break_time"].stringValue == "1 hour" && indexPath.row == 2 {
            cell.lbl_Break.backgroundColor = UIColor.init(named: THEME_COLOR_NAME)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //        let widths = UIScreen.main.bounds.width // 414
        return CGSize(width: self.collectionViewShift.frame.width/3 - 10, height: self.collectionViewShift.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if dicRequestDetail["break_time"].stringValue != "" {
            
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: "", andMessage: "Break has already been selected", on: self)
            
        } else {
            if dicRequestDetail["set_shift"]["shift_break_time"].stringValue == "" {
                if indexPath.row == 0 {
                    
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUPNoBreakVC") as! PopUPNoBreakVC
                    objVC.strHead = "No Break Taken?"
                    objVC.strDesc = "My Shift was more than 6 hours but i got the approval from the manager onsite not to take any break."
                    objVC.strDesc2 = "Key in name of manage above"
                    objVC.delegate = self
                    objVC.strcartid = dicRequestDetail["id"].stringValue
                    objVC.strClienID = dicRequestDetail["client_details"]["id"].stringValue
                    objVC.strFrom = "\(indexPath.row)"
                    objVC.strBreakType = dicRequestDetail["set_shift"]["break_type"].stringValue
                    
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
                    
                } else if indexPath.row == 1 {
                    
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUPNoBreakVC") as! PopUPNoBreakVC
                    objVC.strHead = "You are taking 30 min Break?"
                    objVC.strDesc = "The break timing requires manager approval first as the standard break time is 1 hour."
                    objVC.strDesc2 = "Key in name of manage who approved your 30 mins break"
                    objVC.delegate = self
                    objVC.strcartid = dicRequestDetail["id"].stringValue
                    objVC.strClienID = dicRequestDetail["client_details"]["id"].stringValue
                    objVC.strFrom = "\(indexPath.row)"
                    objVC.strBreakType = dicRequestDetail["set_shift"]["break_type"].stringValue
                    
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
                } else if indexPath.row == 2 {
                    
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUPNoBreakVC") as! PopUPNoBreakVC
                    objVC.strHead = "Start 1 hour Break?"
                    objVC.strDesc = "Before you start break, Kindly ensure to notify your relevant suprvior/manager onsite"
                    objVC.delegate = self
                    objVC.strcartid = dicRequestDetail["id"].stringValue
                    objVC.strClienID = dicRequestDetail["client_details"]["id"].stringValue
                    objVC.strFrom = "\(indexPath.row)"
                    objVC.strBreakType = dicRequestDetail["set_shift"]["break_type"].stringValue
                    
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
                }

            } else {
                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUPNoBreakVC") as! PopUPNoBreakVC
                objVC.strHead = "Start \(dicRequestDetail["set_shift"]["shift_break_time"].stringValue) Break?"
                
                objVC.strDesc = "Before you start break, Kindly ensure to notify your relevant suprvior/manager onsite"
                objVC.delegate = self
                objVC.strcartid = dicRequestDetail["id"].stringValue
                objVC.strClienID = dicRequestDetail["client_details"]["id"].stringValue
                objVC.strFrom = "Dyanamic"
                objVC.strBreakType = dicRequestDetail["set_shift"]["break_type"].stringValue
                objVC.strBreakTime = dicRequestDetail["set_shift"]["shift_break_time"].stringValue
                
                objVC.modalPresentationStyle = .overCurrentContext
                objVC.modalTransitionStyle = .crossDissolve
                self.present(objVC, animated: false, completion: nil)
            }
        }
    }
}

