
import UIKit
import MapKit
import Photos
import CoreTelephony
import SDWebImage

class Utility {
    
    class func isValidEmail(_ email: String) -> Bool {
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        let isValid: Bool = emailPred.evaluate(with: email)
        return isValid
    }
        
    class func getCurrentDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        //        dateFormatter.locale = Locale.current
        dateFormatter.locale = Locale(identifier: "en_US")
        let date:String = dateFormatter.string(from: Date())
        return date
    }
    
    class func getDayNameAccordingToDate(from dateString: String, format: String = "yyyy-MM-dd") -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US") // Set locale to ensure correct day name
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "EEEE" // EEEE gives full day name (e.g., Monday)
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    class func getDate(strDte:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = .current
        return dateFormatter.date(from: strDte)
    }
    
    class func getCurrentShortDate() -> String {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = .current
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let DateInFormat = dateFormatter.string(from: todaysDate)
        
        return DateInFormat
    }
    
    class func getCurrentShortDateNew() -> String {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = .current
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let DateInFormat = dateFormatter.string(from: todaysDate)
        
        return DateInFormat
    }
    
    class func getCurrentTime24HOur() -> String {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let DateInFormat = dateFormatter.string(from: todaysDate)
        
        return DateInFormat
    }

    class func getCurrentDateWithMonth() -> String {
        let todaysDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"
        let DateInFormat = dateFormatter.string(from: todaysDate)
        
        return DateInFormat
    }
        
    class func getDateStringNew(withAMPM dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date: Date? = dateFormatter.date(from: dateString)
        let dateFormatterAMPM = DateFormatter()
        dateFormatterAMPM.dateFormat = "EEEE"
        let dateAMPM: String = dateFormatterAMPM.string(from: date!)
        return dateAMPM
    }
        
    class func showAlertMessage(withTitle title: String, message msg: String, delegate del: Any?, parentViewController parentVC: UIViewController) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        //We add buttons to the alert controller by creating UIAlertActions:
        let actionOk = UIAlertAction(title: "OK", style: .default, handler: nil)
        //You can use a block here to handle a press on this button
        alertController.addAction(actionOk)
        parentVC.present(alertController, animated: true, completion: nil)
    }
    
    class func showAlertWithAction(withTitle title: String, message msg: String, delegate del: Any?, parentViewController parentVC: UIViewController, completionHandler: @escaping (Bool) -> Void ) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style {
            case .default:
                completionHandler(true)
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            @unknown default:
                print("")
            }
        }))
        parentVC.present(alert as UIViewController, animated: true, completion: nil)
    }
    
    class func showAlertYesNoAction(withTitle title: String, message msg: String, delegate del: Any?, parentViewController parentVC: UIViewController, completionHandler: @escaping (Bool) -> Void ) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            switch action.style {
            case .default:
                completionHandler(true)
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            @unknown default:
                print("")
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            switch action.style {
            case .default:
                completionHandler(false)
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            @unknown default:
                print("")
            }
        }))
        parentVC.present(alert as UIViewController, animated: true, completion: nil)
    }
    
    class func convertToMinutes(from text: String) -> Int {
        var total = 0
        if text.contains("hour") {
            if let hour = Int(text.components(separatedBy: " ").first ?? "0") {
                total += hour * 60
            }
        }
        if text.contains("mins") {
            if let mins = Int(text.components(separatedBy: " ").last?.replacingOccurrences(of: "mins", with: "") ?? "0") {
                total += mins
            }
        }
        return total
    }
    
    // For text view
    class func autoresizeTextView(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let textView: UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        textView.font = font
        textView.text = text
        textView.sizeToFit()
        if let textNSString: NSString = textView.text as NSString? {
            let rect = textNSString.boundingRect(with: CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude),
                                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                 attributes: [NSAttributedString.Key.font: textView.font!],
                                                 context: nil)
            textView.frame = CGRect(x: textView.frame.origin.x, y: textView.frame.origin.y, width: textView.frame.size.width, height: rect.height)
        }
        return textView.frame.height
    }
    
    class func isUserLogin ()-> Bool {
        if (USER_DEFAULT.value(forKey: STATUS) != nil) {
            return true
        }
        return false
    }
    
    class func checkNetworkConnectivityWithDisplayAlert( isShowAlert : Bool) -> Bool {
        let isNetworkAvaiable = InternetUtilClass.sharedInstance.hasConnectivity()
        return isNetworkAvaiable;
    }
        
    class func decode(_ s: String) -> String? {
        let data = s.data(using: .utf8)!
        return String(data: data, encoding: .nonLossyASCII)
    }
    
    class func noDataFound(_ message: String, tableViewOt: UITableView, parentViewController parentVC: UIViewController) {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tableViewOt.bounds.width, height: tableViewOt.bounds.height))
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let label: UILabel = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.text = message
        label.textColor = UIColor(red: 90/255, green: 92/255, blue: 99/255, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let label2: UILabel = UILabel()
        label2.font = UIFont.systemFont(ofSize: 13.0)
        label2.text = ""
        label2.textColor = parentVC.hexStringToUIColor(hex: "#95979B")
        label2.textAlignment = .center
        label2.numberOfLines = 0
        label2.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(label2)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -24)
        ])
        
        tableViewOt.backgroundView = containerView
    }
    
    class func noDataFoundColl(_ message: String, tableViewOt: UICollectionView, parentViewController parentVC: UIViewController) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableViewOt.bounds.size.width, height: tableViewOt.bounds.size.height))
        
        _ = (tableViewOt.bounds.size.width/2)
        let center_y = (tableViewOt.bounds.size.height/2)
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: center_y - 25, width: tableViewOt.bounds.size.width, height: 20))
        label.font = label.font.withSize(17.0)
        label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
        label.text = message
        //        label.textColor = parentVC.hexStringToUIColor(hex: "#5A5C63")
        label.textColor = UIColor(red: CGFloat(90)/255, green: CGFloat(92)/255, blue: CGFloat(99)/255, alpha :1)
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 0
        
        let label2: UILabel = UILabel(frame: CGRect(x: 0, y: center_y, width: tableViewOt.bounds.size.width, height: 20))
        label2.font = label.font.withSize(13.0)
        label2.text = "No data available to show"
        label2.textColor = parentVC.hexStringToUIColor(hex: "#95979B")
        label2.textAlignment = NSTextAlignment.center
        label2.numberOfLines = 0
        
        //   view.addSubview(imageView)
        view.addSubview(label)
        //  view.addSubview(label2)
        tableViewOt.backgroundView = view
    }
    
    class func getLocationByCoordinates (location: CLLocation, successBlock success: @escaping (_ address: String) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            // Print fully formatted address
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                let address = (formattedAddress.joined(separator: ", "))
                success(address)
            }
        })
    }
    
    class func setImageWithSDWebImage(_ url: String, _ imageView: UIImageView) {
        let urlwithPercentEscapes = url.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let urlLogo = URL(string: urlwithPercentEscapes!)
        imageView.sd_setImage(with: urlLogo, placeholderImage: UIImage(named: "profile_pla"), options: .continueInBackground, completed: nil)
    }
    
    class func downloadImageBySDWebImage(_ url: String, successBlock success : @escaping ( _ image : UIImage?, _  error: Error?) -> Void) {
        let urlwithPercentEscapes = url.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
        let urlLogo = URL(string: urlwithPercentEscapes!)
        SDWebImageManager.shared().imageDownloader?.downloadImage(with: urlLogo, options: .continueInBackground, progress: nil, completed: { (image, data, error, boool) in
            success(image, error)
        })
    }
    
    /******************************************************************************************/
    //MARK:-  Mapkit
    /******************************************************************************************/
    
    class func initMapViewAnnotation(_ mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        mapView.annotations.forEach {
            if !($0 is MKUserLocation) {
                mapView.removeAnnotation($0)
            }
        }
    }
    
    class func showCurrentLocation(_ mapView: MKMapView, _ vc: UIViewController) {
        let region = MKCoordinateRegion(center: kappDelegate.coordinate2.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        mapView.showsUserLocation = true
        mapView.setRegion(region, animated: true)
    }
    
    class func getLocationByCoordinates (location: CLLocation, successBlock success: @escaping (_ address: String, _ display_address: String) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
            guard let addressDict = placemarks?[0].addressDictionary else {
                return
            }
            var address_display = ""
            if let city = addressDict["City"] as? String {
                if let zip = addressDict["ZIP"] as? String {
                    address_display = city + " " + zip
                }
            }
            
            // Print fully formatted address
            if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                let address = (formattedAddress.joined(separator: ", "))
                success(address, address_display)
            }
        })
    }
}
