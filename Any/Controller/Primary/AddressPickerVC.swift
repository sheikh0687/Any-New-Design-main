//
//  AddressPickerVC.swift
//  Shif
//
//  Created by Techimmense Software Solutions on 20/10/23.
//

import UIKit
import MapKit
import CoreLocation

class AddressPickerVC: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtSearchLocation: UITextView!
    @IBOutlet weak var tableViewOt: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightLocation: NSLayoutConstraint!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var address_display = ""
    var address:String = ""
    var lat:Double?
    var lon:Double?
    var location_cordinate:CLLocationCoordinate2D?
    
    var locationPickedBlock: ((CLLocationCoordinate2D, Double, Double, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if checkLocationPermission(on: self) {
            self.searchCompleter.delegate = self
            self.txtSearchLocation.textColor = .lightGray
            Utility.showCurrentLocation(mapView, self)
            Utility.getLocationByCoordinates(location: kappDelegate.coordinate2) { (address, display_address) in
                self.txtSearchLocation.text = address
                self.location_cordinate = kappDelegate.coordinate2.coordinate
                self.lat = kappDelegate.coordinate2.coordinate.latitude
                self.lon = kappDelegate.coordinate2.coordinate.longitude
                self.address = address
                self.setSearchLocation()
            }
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
            longPressGesture.minimumPressDuration = 1.0
            self.mapView.addGestureRecognizer(longPressGesture)
        } else {
            showLocationDisabledAlert(on: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func checkLocationPermission(on viewController: UIViewController) -> Bool {
        let manager = CLLocationManager()
        // 1. Is system location enabled?
        guard CLLocationManager.locationServicesEnabled() else {
            showLocationDisabledAlert(on: viewController)
            return false
        }
        // 2. What's this app's authorization status?
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            return true
        case .restricted, .denied:
            showLocationDisabledAlert(on: viewController)
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            print("✅ Location access granted")
            return true
        @unknown default:
            showLocationDisabledAlert(on: viewController)
            return false
        }
    }
    
//    func checkLocationPermission(on viewController: UIViewController) -> Bool {
//        var checkNetwork: Bool = false
//        let status = CLLocationManager.authorizationStatus()
//
//        // If location services are turned off completely
//        if !CLLocationManager.locationServicesEnabled() {
//            checkNetwork = false
//        }
//
//        switch status {
//        case .notDetermined:
//            // You can request permission here if needed
//            CLLocationManager().requestWhenInUseAuthorization()
//            checkNetwork = true
//
//        case .restricted, .denied:
//            // User has denied permission → Show alert to go to Settings
//            checkNetwork = false
//
//        case .authorizedAlways, .authorizedWhenInUse:
//            // All good — proceed with location fetching
//            print("✅ Location access granted")
//            checkNetwork = true
//
//        @unknown default:
//            break
//        }
//        
//        return checkNetwork
//    }
    
    func showLocationDisabledAlert(on viewController: UIViewController) {
        let alertController = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services in Settings to use this feature.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        viewController.present(alertController, animated: true)
    }
    
    func updateMapViewAndAnnotation() {
        if CLLocationCoordinate2DIsValid(location_cordinate!) {
            Utility.initMapViewAnnotation(mapView)
            let annotation = MKPointAnnotation()
            annotation.title = self.address
            annotation.coordinate = self.location_cordinate!
            mapView.addAnnotation(annotation)
            
            mapView.mapType = MKMapType.standard
            let span = MKCoordinateSpan.init(latitudeDelta: 0.002, longitudeDelta: 0.002)
            let region = MKCoordinateRegion(center: self.location_cordinate!, span: span)
            self.mapView.setRegion(region, animated: true)
        } else {
            alert(alertmessage: "Location not Found")
        }
    }
    
    func setSearchLocation() {
        if self.address != "" {
            self.txtSearchLocation.text = self.address
            self.txtSearchLocation.textColor = .black
        } else {
            self.txtSearchLocation.text = "Search Location"
            self.tableViewOt.isHidden = true
            searchCompleter.queryFragment = txtSearchLocation.text!
            self.txtSearchLocation.textColor = .lightGray
        }
        let height_location = Utility.autoresizeTextView(self.address, font: UIFont.systemFont(ofSize: 14.0), width: self.txtSearchLocation.frame.width)
        
        if height_location > 17 {
            self.constraintHeightLocation.constant = height_location + 15
        } else {
            self.constraintHeightLocation.constant = height_location + 18
        }
        self.txtSearchLocation.resignFirstResponder()
    }
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            Utility.initMapViewAnnotation(mapView)
            
            let point = gesture.location(in: self.mapView)
            let coordinatee = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            self.lat = coordinatee.latitude
            self.lon = coordinatee.longitude
            self.location_cordinate = coordinatee
            
            Utility.getLocationByCoordinates(location: CLLocation.init(latitude: self.lat!, longitude: self.lon!)) { (address, display_address) in
                self.address_display = display_address
                self.address = address
                self.setSearchLocation()
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.location_cordinate!
            annotation.title = self.address
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func btnAddresclear(_ sender: UIButton) {
        txtSearchLocation.text = ""
        print(txtSearchLocation.text ?? "")
        
        tableViewOt.isHidden = true
        constraintHeightLocation.constant = 33.0
    }
    
    @IBAction func btnSubmitAddress(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.locationPickedBlock?(self.location_cordinate ?? kappDelegate.coordinate2.coordinate, self.lat ?? kappDelegate.coordinate2.coordinate.latitude, self.lon ?? kappDelegate.coordinate2.coordinate.longitude, self.address)
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddressPickerVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.location_cordinate = mapView.centerCoordinate
        self.lat = mapView.centerCoordinate.latitude
        self.lon = mapView.centerCoordinate.longitude
        let cllocation = CLLocation(latitude: self.lat ?? 0.0, longitude: self.lon ?? 0.0)
        Utility.getLocationByCoordinates(location: cllocation) { (address, display_address) in
            self.txtSearchLocation.text = address
            self.address = address
            self.setSearchLocation()
        }
    }
}

extension AddressPickerVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableViewOt.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        
    }
}

extension AddressPickerVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.count < 1 {
            tableViewOt.isHidden = true
        }
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell:SearchLocationCell = tableView.dequeueReusableCell(withIdentifier: "searchLocationCell", for: indexPath) as! SearchLocationCell
        cell.lblMainLocation.text = searchResult.title
        cell.lblSecondaryLocation.text = searchResult.subtitle
        return cell
    }
}

extension AddressPickerVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableViewOt.isHidden = true
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            self.location_cordinate = response?.mapItems[0].placemark.coordinate
            self.address = (response?.mapItems[0].placemark.title)!
            self.lat = response?.mapItems[0].placemark.coordinate.latitude
            self.lon = response?.mapItems[0].placemark.coordinate.longitude
            
            let name = response?.mapItems[0].placemark.name
            let postalCode = response?.mapItems[0].placemark.name
            self.address_display = name! + " " + postalCode!
            self.updateMapViewAndAnnotation()
            self.setSearchLocation()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableHeightConstraint.constant = tableViewOt.contentSize.height
    }
}

extension AddressPickerVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Search Location" && textView.textColor == .lightGray) {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "" && textView.tag == 0) {
            textView.text = "Search Location"
            self.tableViewOt.isHidden = true
            self.searchCompleter.queryFragment = txtSearchLocation.text!
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 0 {
            if textView.text != "" {
                self.tableViewOt.isHidden = false
                self.constraintHeightLocation.constant = 33.0
                print("dd")
            } else {
                self.tableViewOt.isHidden = true
                print("nothing")
            }
            self.searchCompleter.queryFragment = txtSearchLocation.text!
        }
    }
}

