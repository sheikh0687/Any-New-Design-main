//
//  AccurateLocationManager.swift
//  Any
//
//  Created by Pushpendra Mandloi on 24/11/25.
//

import Foundation
import CoreLocation
import UIKit

class AccurateLocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = AccurateLocationManager()

    private let manager = CLLocationManager()
    private var completion: ((CLLocation?) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestAccurateLocation(completion: @escaping (CLLocation?) -> Void) {
        self.completion = completion

        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        manager.requestLocation()      // Gives a FRESH location (not cached)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        completion?(locations.last)
        completion = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?(nil)
        completion = nil
    }
}
