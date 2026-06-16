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
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var txtSearchLocation: UITextView!
    @IBOutlet weak var tableViewOt: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightLocation: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults   = [MKLocalSearchCompletion]()
    
    var address_display      = ""
    var address: String      = ""
    var lat: Double?
    var lon: Double?
    var location_cordinate: CLLocationCoordinate2D?
    
    var locationPickedBlock: ((CLLocationCoordinate2D, Double, Double, String) -> Void)?
    var locationManager: CLLocationManager?
    
    // ── FIX 1: flag to suppress geocode when WE move the map ──
    private var isProgrammaticRegionChange = false
    
    // ── FIX 2: debounce timer so geocode fires only after drag fully stops ──
    private var geocodeDebounceTimer: Timer?
    
    // ── FIX 3: cancel in-flight geocoder before starting a new one ──
    private var activeGeocoder: CLGeocoder?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startLocationFlowIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - Location Permission
    
    func startLocationFlowIfNeeded() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func setupLocationUI() {
        searchCompleter.delegate = self
        txtSearchLocation.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        // Move map to current location without triggering geocode
        moveMapProgrammatically(to: kappDelegate.coordinate2.coordinate)
        
        // Geocode initial position
        reverseGeocodeAndUpdate(coordinate: kappDelegate.coordinate2.coordinate)
        
        // Long-press to drop a pin
        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(addAnnotationOnLongPress(gesture:))
        )
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
    }
    
    func showLocationDisabledAlert(on vc: UIViewController) {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services in Settings to use this feature.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        vc.present(alert, animated: true)
    }
    
    // MARK: - Programmatic Map Move (suppresses geocode)
    
    /// Use this for ALL code-driven region changes so regionDidChangeAnimated
    /// knows to skip geocoding.
    private func moveMapProgrammatically(to coordinate: CLLocationCoordinate2D,
                                         span: MKCoordinateSpan = MKCoordinateSpan(
                                            latitudeDelta: 0.002,
                                            longitudeDelta: 0.002)) {
        isProgrammaticRegionChange = true
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Reverse Geocode (debounced + cancellable)
    
    private func reverseGeocodeAndUpdate(coordinate: CLLocationCoordinate2D) {
        // Cancel previous pending timer
        geocodeDebounceTimer?.invalidate()
        
        // Wait 0.4s after motion stops before hitting geocoder
        geocodeDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.4,
                                                    repeats: false) { [weak self] _ in
            guard let self else { return }
            
            // Cancel any in-flight geocode request
            self.activeGeocoder?.cancelGeocode()
            let geocoder = CLGeocoder()
            self.activeGeocoder = geocoder
            
            // Show "searching" state
            DispatchQueue.main.async {
                self.txtSearchLocation.text      = "Finding address…"
                self.txtSearchLocation.textColor = .lightGray
            }
            
            let location = CLLocation(latitude: coordinate.latitude,
                                      longitude: coordinate.longitude)
            
            geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
                guard let self else { return }
                
                // Ignore stale results if a newer geocode is already running
                guard geocoder === self.activeGeocoder else { return }
                
                DispatchQueue.main.async {
                    if let placemark = placemarks?.first {
                        let parts: [String?] = [
                            placemark.name,
                            placemark.thoroughfare,
                            placemark.locality,
                            placemark.administrativeArea,
                            placemark.country
                        ]
                        let fullAddress = parts.compactMap { $0 }.joined(separator: ", ")
                        
                        self.address             = fullAddress
                        self.location_cordinate  = coordinate
                        self.lat                 = coordinate.latitude
                        self.lon                 = coordinate.longitude
                        
                        self.setSearchLocation()   // updates txtSearchLocation + height
                    } else {
                        self.txtSearchLocation.text      = "Address not found"
                        self.txtSearchLocation.textColor = .lightGray
                    }
                }
            }
        }
    }
    
    // MARK: - Map Annotation Helper
    
    func updateMapViewAndAnnotation() {
        guard let coord = location_cordinate,
              CLLocationCoordinate2DIsValid(coord) else {
            alert(alertmessage: "Location not Found")
            return
        }
        Utility.initMapViewAnnotation(mapView)
        let annotation      = MKPointAnnotation()
        annotation.title    = address
        annotation.coordinate = coord
        mapView.addAnnotation(annotation)
        mapView.mapType     = .standard
        
        // Use programmatic move so regionDidChangeAnimated skips geocode
        moveMapProgrammatically(to: coord)
    }
    
    // MARK: - setSearchLocation
    
    func setSearchLocation() {
        if address.isEmpty {
            txtSearchLocation.text      = "Search Location"
            txtSearchLocation.textColor = .lightGray
            tableViewOt.isHidden        = true
        } else {
            txtSearchLocation.text      = address
            txtSearchLocation.textColor = .black
        }
        
        let height = Utility.autoresizeTextView(
            address,
            font: UIFont.systemFont(ofSize: 14),
            width: txtSearchLocation.frame.width
        )
        constraintHeightLocation.constant = height > 17 ? height + 15 : height + 18
        txtSearchLocation.resignFirstResponder()
    }
    
    // MARK: - Long-press annotation
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .ended else { return }
        
        Utility.initMapViewAnnotation(mapView)
        
        let point      = gesture.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        location_cordinate = coordinate
        lat = coordinate.latitude
        lon = coordinate.longitude
        
        let annotation      = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        // Move map without re-triggering geocode via regionDidChange
        moveMapProgrammatically(to: coordinate)
        
        // Geocode the long-pressed point directly
        reverseGeocodeAndUpdate(coordinate: coordinate)
    }
    
    // MARK: - IBActions
    
    @IBAction func btnAddresclear(_ sender: UIButton) {
        txtSearchLocation.text            = ""
        tableViewOt.isHidden              = true
        constraintHeightLocation.constant = 33.0
        address                           = ""
        searchCompleter.queryFragment     = ""
        searchResults                     = []
        tableViewOt.reloadData()
    }
    
    @IBAction func btnSubmitAddress(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.locationPickedBlock?(
                self.location_cordinate ?? kappDelegate.coordinate2.coordinate,
                self.lat  ?? kappDelegate.coordinate2.coordinate.latitude,
                self.lon  ?? kappDelegate.coordinate2.coordinate.longitude,
                self.address
            )
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension AddressPickerVC: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            // Still waiting for the user to respond — do nothing yet
            break
        case .restricted, .denied:
            showLocationDisabledAlert(on: self)
        case .authorizedWhenInUse, .authorizedAlways:
            // Safe to check services enabled here — off main thread concern is gone
            if CLLocationManager.locationServicesEnabled() {
                setupLocationUI()
            } else {
                showLocationDisabledAlert(on: self)
            }
        @unknown default:
            showLocationDisabledAlert(on: self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        moveMapProgrammatically(to: location.coordinate)
        reverseGeocodeAndUpdate(coordinate: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

// MARK: - MKMapViewDelegate

extension AddressPickerVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // Cancel debounce timer while the user is still dragging
        guard !isProgrammaticRegionChange else { return }
        geocodeDebounceTimer?.invalidate()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // ── KEY FIX ──
        // If WE moved the map, clear the flag and do nothing else.
        if isProgrammaticRegionChange {
            isProgrammaticRegionChange = false
            return
        }
        
        // User dragged the map → geocode the new centre
        reverseGeocodeAndUpdate(coordinate: mapView.centerCoordinate)
    }
}

// MARK: - MKLocalSearchCompleterDelegate

extension AddressPickerVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableViewOt.isHidden = searchResults.isEmpty
        tableViewOt.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter,
                   didFailWithError error: Error) {
        searchResults = []
        tableViewOt.isHidden = true
    }
}

// MARK: - UITableViewDataSource & Delegate

extension AddressPickerVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = searchResults[indexPath.row]
        let cell   = tableView.dequeueReusableCell(
            withIdentifier: "searchLocationCell",
            for: indexPath
        ) as! SearchLocationCell
        cell.lblMainLocation.text      = result.title
        cell.lblSecondaryLocation.text = result.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableViewOt.isHidden = true
        txtSearchLocation.resignFirstResponder()
        
        let completion = searchResults[indexPath.row]
        let request    = MKLocalSearch.Request(completion: completion)
        let search     = MKLocalSearch(request: request)
        
        search.start { [weak self] response, error in
            guard let self,
                  let item = response?.mapItems.first else { return }
            
            let coord = item.placemark.coordinate
            self.location_cordinate = coord
            self.address            = item.placemark.title ?? completion.title
            self.lat                = coord.latitude
            self.lon                = coord.longitude
            
            DispatchQueue.main.async {
                // Move map WITHOUT triggering geocode again
                self.moveMapProgrammatically(to: coord)
                self.setSearchLocation()
                self.updateMapViewAndAnnotation()
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        tableHeightConstraint.constant = tableViewOt.contentSize.height
    }
}

// MARK: - UITextViewDelegate

extension AddressPickerVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text      = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text      = "Search Location"
            textView.textColor = .lightGray
            tableViewOt.isHidden = true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let query = textView.text ?? ""
        if query.isEmpty {
            tableViewOt.isHidden          = true
            searchCompleter.queryFragment = ""
        } else {
            tableViewOt.isHidden          = false
            searchCompleter.queryFragment = query
            constraintHeightLocation.constant = 33.0
        }
    }
}
