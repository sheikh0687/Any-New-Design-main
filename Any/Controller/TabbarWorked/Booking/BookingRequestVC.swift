//
//  BookingRequestVC.swift
//  Any
//
//  Created by mac on 20/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage

class BookingShiftCell: UICollectionViewCell {
    
    @IBOutlet weak var view_Bg: UIView!
    @IBOutlet weak var lbl_Meals: UILabel!
    @IBOutlet weak var lbl_Break: UILabel!
    @IBOutlet weak var lbl_Price: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    @IBOutlet weak var lbl_JobType: UILabel!
}

class HomeClientVCell: UICollectionViewCell {
    
    //    @IBOutlet weak var btn_Book: UIButton!
    @IBOutlet weak var lbl_Two: UILabel!
    @IBOutlet weak var lbl_One: UILabel!
    @IBOutlet weak var main_Vw: UIView!
    @IBOutlet weak var lbl_Three: UILabel!
    @IBOutlet weak var img_Checked: UIImageView!
}

class BookingRequestVC: UIViewController {
    
    @IBOutlet weak var businessLogo_Img: UIImageView!
    
    @IBOutlet weak var lbl_BusinessName: UILabel!
    @IBOutlet weak var coll_date: UICollectionView!
    @IBOutlet weak var lbl_Date: UILabel!
    
    @IBOutlet weak var lbl_Descrip2: UILabel!
    @IBOutlet weak var lbl_Descrip1: UILabel!
    
    @IBOutlet weak var tableViewShift: UITableView!
    @IBOutlet weak var height_TableVw: NSLayoutConstraint!
    
    var dicClinetDetail:JSON!
    
    var arr_List:[JSON] = []
    
    var strDate:String! = ""
    var strlat:String! = ""
    var strlon:String! = ""
    
    let calendar = Calendar.current
    var arrWeekStartEnd:[String] = []
    var arrDateStar:[Date] = []
    var arrDateEnd:[Date] = []
    var arrWeekDAys:[Date] = []
    var currentWeek:Int! = 0
    var arrWeekName:[String] = ["MON","TUE","WED","THU","FRI","SAT","SUN"]
    
    var arrShiftId:[String] = []
    var arrShiftRate:[String] = []
    
    var arrDateS:[String] = []
    var selectDate:Date!
    var strDateOnly: Date!
    
    var arrShiftCount:[JSON] = []
    
    var strSessionJobiD:String! = ""
    var nrcDocumentUpdated: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableViewShift.register(UINib(nibName: "ShiftCell", bundle: nil), forCellReuseIdentifier: "ShiftCell")
        
        lbl_BusinessName.text = "\(dicClinetDetail["business_name"].stringValue)\n\(dicClinetDetail["business_address"].stringValue)"
        if Router.BASE_IMAGE_URL != dicClinetDetail["business_logo"].stringValue {
            Utility.setImageWithSDWebImage(dicClinetDetail["business_logo"].stringValue, self.businessLogo_Img)
        } else {
            self.businessLogo_Img.image = R.image.placeholder_2()
        }
        
        let formatter = DateFormatter()
        
        // Set the time zone to Singapore
        formatter.timeZone = TimeZone(abbreviation: "SGT") // or use "Asia/Singapore"
        
        // Set the date and time format
        formatter.dateFormat = "yyyy-MM-dd"
        
        strDate = formatter.string(from: strDateOnly)
        
        selectDate = formatter.date(from: strDate)
        
        GetProfile()
        getDataShiftAvailble()
        
        let lastDayOfTheYear = Calendar.current.date(byAdding: .day, value: 100, to: Date())
        var currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "SGT")
        dateFormatter.dateFormat = "ccc"
        
        let dayOfWeek = dateFormatter.string(from: currentDate)
        
        print("Current Date Before Condition According to Singapore: \(currentDate)")
        
        let components = calendar.dateComponents([.hour], from: currentDate)
        
        if let hours = components.hour, hours >= 0 && hours < 6 {
            currentDate = calendar.date(byAdding: .hour, value: 8, to: currentDate)!
        }
        
        print("Current Date After Condition According to Singapore: \(currentDate)")
        
        while currentDate < lastDayOfTheYear! {
            var startDay: String!
            var endDay: String!
            
            if dayOfWeek == "Mon" {
                startDay = currentDate.formatted()
            } else {
                startDay = currentDate.previous(.monday).formatted()
            }
            
            if dayOfWeek == "Sun" {
                endDay = currentDate.formatted()
            } else {
                endDay = currentDate.next(.sunday).formatted()
            }
            
            if selectDate > getDate(strDte: endDay)! {
                currentWeek += 1
            }
            arrWeekStartEnd.append("\(startDay!),\(endDay!)")
            arrDateStar.append(getDate(strDte: startDay)!)
            arrDateEnd.append(getDate(strDte: endDay)!)
            
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        setNavigationBarItem(LeftTitle: "", LeftImage: "BackArrow", CenterTitle: "Booking Request", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        
        var dcuureDate = arrDateStar[currentWeek]
        while dcuureDate <= arrDateEnd[currentWeek] {
            arrWeekDAys.append(dcuureDate)
            dcuureDate = Calendar.current.date(byAdding: .day, value: 1, to: dcuureDate)!
        }
        coll_date.reloadData()
        getDataGetList()
    }
    
    func getDate(strDte:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = .current
        return dateFormatter.date(from: strDte)
    }
    
    @IBAction func back(_ sender: Any) {
        
        if currentWeek > 0 {
            
            arrWeekDAys = []
            currentWeek -= 1
            
            var dcuureDate = arrDateStar[currentWeek]
            while dcuureDate <= arrDateEnd[currentWeek] {
                arrWeekDAys.append(dcuureDate)
                dcuureDate = Calendar.current.date(byAdding: .day, value: 1, to: dcuureDate)!
            }
//            coll_date.reloadData()
            getDataGetList()
        }
        
    }
    
    @IBAction func next(_ sender: Any) {
        
        arrWeekDAys = []
        currentWeek += 1
        var dcuureDate = arrDateStar[currentWeek]
        while dcuureDate <= arrDateEnd[currentWeek] {
            arrWeekDAys.append(dcuureDate)
            dcuureDate = Calendar.current.date(byAdding: .day, value: 1, to: dcuureDate)!
        }
//        coll_date.reloadData()
        getDataGetList()
    }
}

//MARK: API
extension BookingRequestVC {
    
    func GetProfile() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_profile.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    if let jobiD = swiftyJsonVar["result"]["job_type_id"].string {
                        self.strSessionJobiD = jobiD
                        print(self.strSessionJobiD ?? "")
                    }
                } else {
                    _ = swiftyJsonVar["result"].string
                }
                self.hideProgressBar()
            }
            
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }

    
    func webAddToCartSubmit(_ shiftId: String,_ shiftRate: String) {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        
        var arrClinId:[String] = []
        var arrDayName:[String] = []
        var arrDate:[String] = []
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date? = dateFormatter.date(from: strDate)
        let dateFormatterAMPM = DateFormatter()
        dateFormatterAMPM.dateFormat = "yyyy-MM-dd"
        let dateAMPM: String = dateFormatterAMPM.string(from: date!)
        
        arrClinId.append(dicClinetDetail["id"].stringValue)
        arrDayName.append(Utility.getDateStringNew(withAMPM: strDate))
        arrDate.append(dateAMPM)
        
        paramsDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramsDict["client_id"]     =  arrClinId.joined(separator: ",")  as AnyObject
        paramsDict["shift_id"]     =  shiftId as AnyObject
        paramsDict["day_name"]     =  arrDayName.joined(separator: ",")  as AnyObject
        paramsDict["date"]     =  arrDate.joined(separator: ",")  as AnyObject
        paramsDict["shift_rate"]     =  shiftRate as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.add_to_set_shift_cart.url(), parameters: paramsDict,  parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"] == "1") {
                    let cartId = swiftyJsonVar["cart_id"].int
                    self.addBookingFinal(cartId ?? 0)
                } else {
                    let message = swiftyJsonVar["message"].stringValue
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message, on: self)
                }
                self.hideProgressBar()
            }
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    func chnageDataAccordingDate(doc:JSON)  {
        lbl_Descrip1.text = "Job Type: \(doc["job_type"].stringValue)"
        lbl_Descrip2.text = "Note: \(doc["note"].stringValue)"
    }
    
    func getDataGetList() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   dicClinetDetail["id"].stringValue as AnyObject
        let strDat = arrWeekStartEnd[currentWeek]
        let arr = strDat.components(separatedBy: ",")
        paramDict["start_date"]  =  arr[0] as AnyObject
        paramDict["end_date"]  =   arr[1] as AnyObject
        paramDict["worker_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_shift_by_day_week_count.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arrShiftCount = swiftyJsonVar["result"].arrayValue
                    self.coll_date.reloadData()
                } else {
                    self.arrShiftCount = []
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func getDataShiftAvailble() {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["client_id"]  =   dicClinetDetail["id"].stringValue as AnyObject
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date? = dateFormatter.date(from: strDate)
        let dateFormatterAMPM = DateFormatter()
        dateFormatterAMPM.dateFormat = "yyyy-MM-dd"
        let dateAMPM: String = dateFormatterAMPM.string(from: date!)
        
        paramDict["sel_date"]  =   dateAMPM as AnyObject
        
        paramDict["day_name"]  =   Utility.getDateStringNew(withAMPM: strDate) as AnyObject
        
        print("paramDict\(paramDict)")
        
        CommunicationManager.callPostService(apiUrl: Router.get_shift_by_day.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_List  = swiftyJsonVar["result"].arrayValue
                    self.nrcDocumentUpdated = swiftyJsonVar["nrc_document_uploaded"].stringValue
                    self.chnageDataAccordingDate(doc: self.arr_List [0])
                    
                    self.tableViewShift.backgroundView = UIView()
                    self.height_TableVw.constant = CGFloat(200 * self.arr_List.count)
                    self.tableViewShift.reloadData()
                } else {
                    self.arr_List = []
                    self.tableViewShift.backgroundView = UIView()
                    self.tableViewShift.reloadData()
                    Utility.noDataFound("No Shift Available", tableViewOt: self.tableViewShift, parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func addBookingFinal(_ cartID: Int) {
        
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =  USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["cart_id"]  =  cartID as AnyObject
        paramDict["date"]  =  "" as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.add_set_shift_book.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PopUpVC") as! PopUpVC
                    objVC.strFrom = "Summery"
                    objVC.str_Head = "Your Booking Request Has Been Sent"
                    objVC.str_Desc = "You will receive a notification once the unit manager has approved/declined your shift."
                    objVC.completion = {
                        Switcher.updateRootVC()
                    }
                    objVC.modalPresentationStyle = .overCurrentContext
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: false, completion: nil)
                } else {
                    Utility.showAlertMessage(withTitle: APPNAME, message: "Some went wrong", delegate: self, parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func webDeletShift(strCartiD:String) {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["cart_id"]  =   strCartiD as AnyObject
        paramDict["status"]  =   "Cancel" as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.change_set_shift_status_worker_side.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.getDataShiftAvailble()
                } else {
                    Utility.showAlertMessage(withTitle: EMPTY_STRING, message: swiftyJsonVar["message"].stringValue, delegate: nil,parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func webWorkerUpdateDocc(workerDocc: UIImage)
    {
        showProgressBar()
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramDict)
        
        var paramImgDict: [String : UIImage] = [:]
        paramImgDict["nrc_document"] = workerDocc

        print(paramImgDict)
        
        CommunicationManager.uploadImagesAndData(apiUrl: Router.worker_update_document.url(), params: (paramDict as! [String : String]) , imageParam: paramImgDict, videoParam: [:], parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async { [self] in
                let swiftyJsonVar = JSON(responseData)
                print(swiftyJsonVar)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    Utility.showAlertWithAction(withTitle: "", message: "Your account is pending approval and you will receive notifications once you are authorized to book jobs.", delegate: self, parentViewController: self) { issy in
                        Switcher.updateRootVC()
                    }
                } else {
                    let message = swiftyJsonVar["message"].stringValue
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message, on: self)
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
}

extension BookingRequestVC: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrShiftCount.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeClientVCell
        
        let strdate = arrWeekDAys[indexPath.row]
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.locale = .current
        
        formatter.dateFormat = "dd"
        cell.lbl_Two.text = formatter.string(from: strdate)
        print(cell.lbl_Two.text!)
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        let shortDate = formatter.string(from: strdate)
        
        if shortDate == strDate {
            cell.backgroundColor = .white
            cell.cornerRadius1 = 20
            cell.lbl_Two.textColor =  UIColor.init(named: "BUTTON_COLOR")
        } else {
            cell.backgroundColor = .clear
            cell.lbl_Two.textColor =  .black
        }
        
        formatter.dateFormat = "MMM yyyy"
        lbl_Date.text = formatter.string(from: strdate)
        cell.lbl_One.text = arrWeekName[indexPath.row]
        
        let dict = self.arrShiftCount[indexPath.row]
        if let statuss = dict["selected_day_my_booking_status"].string {
            switch statuss {
            case "Available":
                cell.lbl_Three.isHidden = false
                cell.lbl_Three.text = dict["shift_count"].stringValue
                cell.img_Checked.isHidden = true
            case "Accepted":
                cell.lbl_Three.isHidden = true
                cell.img_Checked.isHidden = false
                cell.img_Checked.image = R.image.accepted()
            case "Pending":
                cell.lbl_Three.isHidden = true
                cell.img_Checked.isHidden = false
                cell.img_Checked.image = R.image.pending()
            case "Full":
                cell.lbl_Three.isHidden = true
                cell.img_Checked.isHidden = false
                cell.img_Checked.image = R.image.full()
            default:
                cell.lbl_Three.isHidden = false
                cell.lbl_Three.text = dict["shift_count"].stringValue
                cell.lbl_Three.borderColor1 = .gray
                cell.img_Checked.isHidden = true
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.coll_date.frame.width/7 - 8, height: self.coll_date.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! HomeClientVCell
        let strdate = arrWeekDAys[indexPath.row]
        let formatter = DateFormatter()
        //            formatter.timeZone = TimeZone(identifier: "Asia/Singapore")
        formatter.timeZone = TimeZone.current
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd"
        
        strDate = formatter.string(from: strdate)
        let curre = formatter.string(from: Date())
        
        print("strDatestrDate \(strdate)")
        print("Utility.getCurrentShortDate() \(curre)")
        print("Utility.getCurrentShortDate() \(String(describing: getDate(strDte: curre)))")
        let dateNd = getDate(strDte: curre)!
        
        if dateNd <= strdate {
            
            cell.backgroundColor = .white
            cell.cornerRadius1 = 20
            cell.lbl_Two.textColor =  UIColor.init(named: "BUTTON_COLOR")
            
            let indexPathh = collectionView.indexPathsForVisibleItems
            for indexPathOth in indexPathh {
                if indexPathOth.row != indexPath.row && indexPathOth.section == indexPath.section {
                    let cell = collectionView.cellForItem(at: IndexPath(row: indexPathOth.row, section: indexPathOth.section)) as? HomeClientVCell
                    cell?.backgroundColor = .clear
                    cell?.lbl_Two.textColor =  .black
                }
            }
            
            getDataShiftAvailble()
        }
    }
}

extension BookingRequestVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_List.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShiftCell", for: indexPath) as! ShiftCell
        
        let dic = self.arr_List[indexPath.row]
        
        cell.lbl_ShiftTime.text = "\(dic["start_time"].stringValue) to \(dic["end_time"].stringValue)"
        cell.lbl_Hour.text = "\(dic["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue)/Hour"
        cell.lbl_Break.text = "Break: \(dic["break_type"].stringValue)"
        cell.lbl_BreakTime.text = "Break Time: \(dic["shift_break_time"].stringValue)"
        cell.lbl_Meal.text = "Meals: \(dic["meals"].stringValue)"
        cell.lbl_JobType.text = "Job Type: \(dic["job_type"].stringValue)"
        cell.lbl_Note.text = "Note: \(dic["note"].stringValue)"
                
        let shiftCartStatus = dic["set_shift_cart_status_value"].stringValue
        let bookingStatus = dic["booking_status"].stringValue
        let booking = dic["booking"].stringValue
        
        cell.view_Bg.borderWidth1 = 0.5

        if dic["client_details"]["shift_autoapproval"].stringValue == "Yes" {
            cell.lbl_InstantApproval.isHidden = false
        } else {
            cell.lbl_InstantApproval.isHidden = true
        }
        
        if shiftCartStatus == "Accept" {
            cell.view_Bg.borderColor1 = R.color.greeN()
            cell.lbl_Status.text = "Booking\nAccepted!"
            cell.lbl_Status.textColor = R.color.greeN()
            cell.btn_BookOt.isHidden = true
            cell.btn_ClosedOt.isHidden = true
            cell.btn_WithdrawOt.isHidden = false
        } else if shiftCartStatus == "Complete" {
            cell.view_Bg.borderColor1 = R.color.greeN()
            cell.lbl_Status.text = "Booking\nComplete!"
            cell.lbl_Status.textColor = R.color.greeN()
            cell.btn_BookOt.isHidden = true
            cell.btn_ClosedOt.isHidden = true
            cell.btn_WithdrawOt.isHidden = true

        } else if shiftCartStatus == "Pending" {
            cell.view_Bg.borderColor1 = R.color.button_COLOR()
            cell.lbl_Status.text = "Pending\nConfirmation!"
            cell.lbl_Status.textColor = R.color.button_COLOR()
            
            cell.btn_BookOt.isHidden = true
            cell.btn_ClosedOt.isHidden = true
            cell.btn_WithdrawOt.isHidden = false
        } else {
            if bookingStatus == "Close" {
                cell.view_Bg.borderColor1 = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                cell.lbl_Status.text = "Booking\nClosed!"
                cell.lbl_Status.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                
                cell.btn_BookOt.isHidden = true
                cell.btn_WithdrawOt.isHidden = true
                cell.btn_ClosedOt.isHidden = false
            } else {
                if booking == "Full" {
                    cell.view_Bg.borderColor1 = UIColor.red
                    cell.lbl_Status.text = "Booking\nFull!"
                    cell.lbl_Status.textColor = UIColor.red
                    
                    cell.btn_BookOt.isHidden = true
                    cell.btn_WithdrawOt.isHidden = true
                    cell.btn_ClosedOt.isHidden = false
                } else {
                    cell.view_Bg.borderColor1 = .separator
                    cell.lbl_Status.text = "Available"
                    cell.lbl_Status.textColor = R.color.greeN()
                    
                    cell.btn_BookOt.isHidden = false
                    cell.btn_WithdrawOt.isHidden = true
                    cell.btn_ClosedOt.isHidden = true
                }
            }
        }
        
        cell.cloBook = { [self] in
            if nrcDocumentUpdated == "Yes" {
                if dic["document_requied"].stringValue == "Yes" {
                    if strSessionJobiD == dic["job_type_id"].stringValue {
                        let vC = R.storyboard.main().instantiateViewController(withIdentifier: "PopUpBeforeBooking") as! PopUpBeforeBooking
                        
                        let objClient = dic["client_details"].dictionaryValue
                        vC.strBookinName = "\(objClient["business_name"]?.stringValue ?? ""),\n\(objClient["business_address"]?.stringValue ?? "")\n\(dic["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue)/Hour"
                        
                        vC.strBookingDetail = "Job Type : \(dic["job_type"].stringValue)\nBreak : \(dic["break_type"].stringValue)\nMeals : \(dic["meals"].stringValue)"
                        
                        vC.strBookingNote = dic["note"].stringValue
                        vC.strInstantApproval = dic["shift_autoapproval"].stringValue
                        vC.isFrom = "Book"
                        
                        vC.cloBook = { [self] in
                            let shiftId = dic["id"].stringValue
                            let shiftRate = dic["shift_rate"].stringValue
                            self.webAddToCartSubmit(shiftId, shiftRate)
                        }
                        
                        vC.modalTransitionStyle = .crossDissolve
                        vC.modalPresentationStyle = .overFullScreen
                        self.present(vC, animated: true)
                    } else {
                        Utility.showAlertMessage(withTitle: APPNAME, message: "Please complete your profile to book.\n\n * Go to Profile, select the job type you’re applying for.\n * Some roles (Kitchen Assistant, Chef, Barista) require a one-time upload of NRIC and a valid Food Hygiene Certificate.\n\nOnce approved, you can book shifts for that job type.", delegate: self, parentViewController: self)
                    }
                } else {
                    let vC = R.storyboard.main().instantiateViewController(withIdentifier: "PopUpBeforeBooking") as! PopUpBeforeBooking
                    
                    let objClient = dic["client_details"].dictionaryValue
                    vC.strBookinName = "\(objClient["business_name"]?.stringValue ?? ""),\n\(objClient["business_address"]?.stringValue ?? "")\n\(dic["currency_symbol"].stringValue)\(dic["shift_rate"].stringValue)/Hour"
                    
                    vC.strBookingDetail = "Job Type : \(dic["job_type"].stringValue)\nBreak : \(dic["break_type"].stringValue)\nMeals : \(dic["meals"].stringValue)"
                    
                    vC.strBookingNote = dic["note"].stringValue
                    vC.strInstantApproval = dic["shift_autoapproval"].stringValue
                    vC.isFrom = "Book"
                    
                    vC.cloBook = { [self] in
                        let shiftId = dic["id"].stringValue
                        let shiftRate = dic["shift_rate"].stringValue
                        self.webAddToCartSubmit(shiftId, shiftRate)
                    }
                    
                    vC.modalTransitionStyle = .crossDissolve
                    vC.modalPresentationStyle = .overFullScreen
                    self.present(vC, animated: true)
                }
            } else {
                let vC = R.storyboard.main().instantiateViewController(withIdentifier: "PopNRIC") as! PopNRIC
                vC.cloSubmit = { doccImg in
                    self.webWorkerUpdateDocc(workerDocc: doccImg)
                }
                vC.modalTransitionStyle = .crossDissolve
                vC.modalPresentationStyle = .overFullScreen
                self.present(vC, animated: true)
            }
        }
        
        cell.cloWithdraw = { [self] in
            let vC = R.storyboard.main().instantiateViewController(withIdentifier: "PopUpBeforeBooking") as! PopUpBeforeBooking
            let objClient = dic["client_details"].dictionaryValue
            vC.strBookinName = "\(objClient["business_name"]?.stringValue ?? ""),\n\(objClient["business_address"]?.stringValue ?? "")\n\(dic["day_name"].stringValue) \(dic["start_time"].stringValue) \(dic["end_time"].stringValue)"
            vC.isFrom = "Withdraw"
            vC.isPendingBooking = shiftCartStatus
            
            vC.cloBook = { [self] in
                self.webDeletShift(strCartiD: dic["set_shift_cart_id"].stringValue)
                self.dismiss(animated: true)
            }
            
            vC.modalTransitionStyle = .crossDissolve
            vC.modalPresentationStyle = .overFullScreen
            self.present(vC, animated: true)
        }
        
        cell.cloClosed = { [self] in
            Utility.showAlertMessage(withTitle: APPNAME, message: "Closed for booking", delegate: self, parentViewController: self)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
