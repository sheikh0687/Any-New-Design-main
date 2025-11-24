//
//  NewBookingVC.swift
//  Any
//
//  Created by mac on 19/05/23.
//

import UIKit
import SwiftyJSON
import SDWebImage
import MapKit
import DropDown

class NewBookingVC: UIViewController,UITextFieldDelegate  {
    
    @IBOutlet weak var table_List: UITableView!
    @IBOutlet weak var textSerach: UITextField!
    @IBOutlet weak var clientList_TableVw: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchActive : Bool = false
    var searchResults = [MKLocalSearchCompletion]()
    var searchCompleter = MKLocalSearchCompleter()
    
    var strlat:String! = ""
    var strlon:String! = ""
    
    var arr_List:[JSON] = []
    var arr_FilterList:[JSON] = []
    
    var drop = DropDown()
    var arr_AllDates:[JSON] = []
    var strDay:String! = ""
    var strDate:String! = ""
    var strDateOnly:Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clientList_TableVw.register(UINib(nibName: "ClientListCell", bundle: nil), forCellReuseIdentifier: "ClientListCell")
        
        searchCompleter.delegate = self
        searchCompleter.region = MKCoordinateRegion(center: kappDelegate.coordinate2.coordinate, latitudinalMeters: 10_000, longitudinalMeters: 10_000)
        
        textSerach.delegate = self
        textSerach.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                             for: UIControl.Event.editingChanged)
        
        table_List.estimatedRowHeight = 100
        table_List.rowHeight = UITableView.automaticDimension
        
        getListOfDatesShift()
        searchBar.delegate = self
        setupSearchBar(for: searchBar)
        
        strlat = kappDelegate.CURRENT_LAT
        strlon = kappDelegate.CURRENT_LON

        strDate = Utility.getCurrentShortDate()
        strDay = Utility.getCurrentDay()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        setNavigationBarItem(LeftTitle: "", LeftImage: "", CenterTitle: "Search Jobs", CenterImage: "", RightTitle: "", RightImage: "", BackgroundColor: OFFWHITE_COLOR, BackgroundImage: "", TextColor: BLACK_COLOR, TintColor: BLACK_COLOR, Menu: "")
        //   GetProfile()
        table_List.isHidden = true
        
        
        getAddressFromLatLon(pdblLatitude: kappDelegate.CURRENT_LAT, withLongitude: kappDelegate.CURRENT_LON)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getClientList(strJobiD: "", strJobName: "")
    }
    
    //MARK: Searchfirld delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchActive = false;
        table_List.isHidden = true
        table_List.reloadData()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        let searchText  = textField.text!
        if searchText.count >= 1 {
            searchActive = true
            searchCompleter.queryFragment = searchText
            table_List.isHidden = false
        } else {
            searchActive = false;
            table_List.isHidden = true
        }
    }
    
    public func setupSearchBar(for search_Bar: UISearchBar) {
        search_Bar.placeholder = "Search outlet name"
        search_Bar.barTintColor = .systemGray6
        search_Bar.searchTextField.backgroundColor = .clear
        search_Bar.searchTextField.textColor = UIColor.black
        
        if let clearButton = search_Bar.searchTextField.value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        
        search_Bar.layer.cornerRadius = 20
        search_Bar.layer.borderWidth = 0
        search_Bar.layer.masksToBounds = true
    }
    
    @IBAction func Cross(_ sender: Any) {
        searchActive = false;
        textSerach.text = ""
        table_List.isHidden = true
    }
    
    func getListOfDatesShift() {
        showProgressBar()
        var paramsDict:[String:AnyObject] = [:]
        paramsDict["user_id"] = USER_DEFAULT.value(forKey: USERID) as AnyObject
        
        print(paramsDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_days_List.url(), parameters: paramsDict, parentViewController: self, successBlock: { (responseData, message) in
            
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.arr_AllDates = swiftyJsonVar["result"].arrayValue
                    print(self.arr_AllDates.count)
                } else {
                    let message = swiftyJsonVar["result"].string
                    GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: message!, on: self)
                }
                self.hideProgressBar()
            }
            
        },failureBlock: { (error : Error) in
            self.hideProgressBar()
            GlobalConstant.showAlertMessage(withOkButtonAndTitle: APPNAME, andMessage: (error.localizedDescription), on: self)
        })
    }
    
    @IBAction func Today(_ sender: UIButton) {
        drop.anchorView = sender
        drop.direction = .bottom
        drop.dataSource = arr_AllDates.map( {$0["day"].stringValue})
        drop.show()
        drop.bottomOffset = CGPoint(x: 0, y: 45)
        drop.selectionAction = { [unowned self] (index: Int, item: String) in
            sender.setTitle(item, for: .normal)
            self.strDay = arr_AllDates[index]["dayname"].stringValue
            self.strDate = arr_AllDates[index]["date"].stringValue
            print(strDate!)
            let strContainDate = arr_AllDates[index]["date"].stringValue
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.locale = .current
            formatter.dateFormat = "yyyy-MM-dd"
            self.strDateOnly = formatter.date(from: strContainDate)
            getClientList(strJobiD: "", strJobName: "")
        }
    }
    
    @IBAction func btn_Filter(_ sender: UIButton) {
        let vC = R.storyboard.main().instantiateViewController(withIdentifier: "PopupjobTypeVC") as! PopupjobTypeVC
        vC.cloJobType = { [weak self] strJobName, strJobiD in
            guard let self else { return }
            getClientList(strJobiD: strJobiD, strJobName: strJobName)
        }
        vC.modalTransitionStyle = .crossDissolve
        vC.modalPresentationStyle = .overFullScreen
        self.present(vC, animated: true)
    }
    
    func getClientList(strJobiD: String, strJobName: String) {
        showProgressBar()
        
        var paramDict : [String:AnyObject] = [:]
        paramDict["user_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["lat"]  =   strlat as AnyObject
        paramDict["lon"]  =   strlon as AnyObject
        paramDict["finddate"]  =   strDate as AnyObject
        paramDict["day_name"]  =   strDay as AnyObject
        paramDict["cat_id"]  =   "0" as AnyObject
        paramDict["country_id"] = USER_DEFAULT.value(forKey: COUNTRYID) as AnyObject
        paramDict["job_type_id"] = strJobiD as AnyObject
        paramDict["job_type_name"] = strJobName as AnyObject
        
        print(paramDict)
        
        CommunicationManager.callPostService(apiUrl: Router.get_client_list.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    let resultArr = swiftyJsonVar["result"].arrayValue

                    let available = resultArr.filter { $0["booking_status"].stringValue == "Open" }
                    let closed = resultArr.filter { $0["booking_status"].stringValue != "Open" }

                    let finalArr = available + closed

                    self.arr_List = finalArr
                    self.arr_FilterList = finalArr
                    
                    self.clientList_TableVw.backgroundView = UIView()
                    self.clientList_TableVw.reloadData()
                } else {
                    self.arr_List = []
                    self.arr_FilterList = []
                    self.clientList_TableVw.backgroundView = UIView()
                    self.clientList_TableVw.reloadData()
                    Utility.noDataFound("No Bookings At The Moment", tableViewOt: self.clientList_TableVw, parentViewController: self)
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    { [self](placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            
            if pm.count > 0 {
                let pm = placemarks![0]
                print(pm.country as Any)
                print(pm.locality as Any)
                print(pm.subLocality as Any)
                print(pm.thoroughfare as Any)
                print(pm.postalCode as Any)
                print(pm.subThoroughfare as Any)
                var addressString : String = ""
                if pm.subLocality != nil {
                    addressString = addressString + pm.subLocality! + ", "
                }
                if pm.thoroughfare != nil {
                    addressString = addressString + pm.thoroughfare! + ", "
                }
                if pm.locality != nil {
                    addressString = addressString + pm.locality! + ", "
                }
                if pm.country != nil {
                    addressString = addressString + pm.country! + ", "
                }
                if pm.postalCode != nil {
                    addressString = addressString + pm.postalCode! + " "
                }
                
                textSerach.text = addressString
                print(addressString)
            }
        })
    }
    
    func getLikeUnlike(strClientiD:String) {
        showProgressBar()
        
        var paramDict : [String:AnyObject] = [:]
        paramDict["worker_id"]  =   USER_DEFAULT.value(forKey: USERID) as AnyObject
        paramDict["client_id"]  =   strClientiD as AnyObject
        
        print("Do print the \(paramDict)")
        
        CommunicationManager.callPostService(apiUrl: Router.like_unlike.url(), parameters: paramDict, parentViewController: self, successBlock: { (responseData, message) in
            DispatchQueue.main.async {
                let swiftyJsonVar = JSON(responseData)
                if(swiftyJsonVar["status"].stringValue == "1") {
                    self.getClientList(strJobiD: "", strJobName: "")
                }
                self.hideProgressBar()
            }
        }, failureBlock: { (error : Error) in
            Utility.showAlertMessage(withTitle: EMPTY_STRING, message: (error.localizedDescription), delegate: nil,parentViewController: self)
            self.hideProgressBar()
        })
    }
}


extension NewBookingVC : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == table_List {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == table_List {
            return searchResults.count
        } else {
            return self.arr_List.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == table_List {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! BookingCellWorker
            
            let dic = searchResults[indexPath.row]
            print(dic)
            cell.lbl_Address.text = dic.title + " " + dic.subtitle
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ClientListCell", for: indexPath) as! ClientListCell
            
            let dic = self.arr_List[indexPath.row]
            
            cell.lbl_BusinessName.text = (dic["business_name"].stringValue)
            cell.lbl_Address.text = "Address: \(dic["business_address"].stringValue)"
            
            if Router.BASE_IMAGE_URL != dic["business_logo"].stringValue {
                Utility.setImageWithSDWebImage(dic["business_logo"].stringValue, cell.clientLogo_Img)
            } else {
                cell.clientLogo_Img.image = R.image.placeholder_2()
            }
            
            if dic["booking_status"].stringValue == "Open" {
                cell.lbl_AvailbaleStatus.text = "Available"
                cell.lbl_AvailbaleStatus.textColor = hexStringToUIColor(hex: "#04a431")
            } else {
                cell.lbl_AvailbaleStatus.text = "Not Available"
                cell.lbl_AvailbaleStatus.textColor = hexStringToUIColor(hex: "#AEACAC")
            }
            
            if dic["shift_autoapproval"].stringValue == "Yes" {
                cell.lbl_InstantApproval.isHidden = false
            } else {
                cell.lbl_InstantApproval.isHidden = true
            }
            
            if dic["fav_status"].stringValue == "Yes" {
                cell.btn_LikeOt.setImage(R.image.fav_add(), for: .normal)
            } else {
                cell.btn_LikeOt.setImage(R.image.unfav(), for: .normal)
            }
            
            cell.cloLike = {
                self.getLikeUnlike(strClientiD: dic["id"].stringValue)
            }
            
            return cell
        }
    }
}

extension NewBookingVC : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == table_List {
            
            let dic = searchResults[indexPath.row]
            textSerach.text = dic.title + " " + dic.subtitle
            
            let searchRequest = MKLocalSearch.Request(completion: searchCompleter.results[indexPath.row])
            let search = MKLocalSearch(request: searchRequest)
            search.start { [self] (response, error) in
                let placemark = response?.mapItems[0].placemark
                table_List.isHidden = true
                textSerach.resignFirstResponder()
                print("\(placemark?.coordinate)")
                strlat = "\(placemark?.coordinate.latitude ?? 0.0)"
                strlon = "\(placemark?.coordinate.longitude ?? 0.0)"
            }
        } else {
            if Utility.isUserLogin() {
                let dic = self.arr_List[indexPath.row]
                
                let objVC = kStoryboardMain.instantiateViewController(withIdentifier: "BookingRequestVC") as! BookingRequestVC
                objVC.dicClinetDetail = dic
                if strDateOnly != nil {
                    objVC.strDateOnly = strDateOnly
                } else {
                    let strContainDate = Date()
                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone.current
                    formatter.locale = .current
                    formatter.dateFormat = "yyyy-MM-dd"
                    let strConvertedDate = formatter.string(from: strContainDate)
                    objVC.strDateOnly = formatter.date(from: strConvertedDate)
                }
                objVC.strDate = self.strDate
                self.navigationController?.pushViewController(objVC, animated: true)
            } else {
                self.alert(alertmessage: "Please create an account to use this feature.")
            }
        }
    }
}


extension NewBookingVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        print("result result \(searchResults)")
        table_List.reloadData()
    }
}
    
extension NewBookingVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.arr_List = self.arr_FilterList
        if !searchText.isEmpty {
            let lowercaseSearchText = searchText.lowercased()

            // Filtering JSON array
            let filteredArr = self.arr_FilterList.filter { json in
                // Extract string safely using .stringValue
                let businessName = json["business_name"].stringValue.lowercased()

                return businessName.hasPrefix(lowercaseSearchText)
            }

            self.arr_List = filteredArr
        }
        self.clientList_TableVw.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.clientList_TableVw.endEditing(true)
        self.searchBar.endEditing(true)
        searchBar.resignFirstResponder()
    }
}

