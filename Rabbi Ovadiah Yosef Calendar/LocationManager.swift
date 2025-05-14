//
//  LocationManager.swift
//  Rabbeinu Tam
//
//  Created by Elyahu on 1/22/22.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    
    var completion: ((CLLocation?) -> Void)?
    
    public func getUserLocation(completion: @escaping ((CLLocation?) -> Void)) {
        self.completion = completion
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            completion?(nil)
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        completion?(nil)
    }
    
    public func resolveLocationName(with location: CLLocation, completion: @escaping ((String?) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: nil) { placemarks, error in
            guard let place = placemarks?.first, error == nil else {
                print("Error getting location")
                completion(nil)
                return
            }
            
            var name = ""
            var strings = Array<String>()
            
            let useSubLocalOnly = place.locality?.split(separator: " ").map({ String($0.first!) }).joined() == place.administrativeArea
            
            if let subLocality = place.subLocality {
                strings.append(subLocality)
            }
            
            if !useSubLocalOnly, let locality = place.locality {
                strings.append(locality)
            }
            
            if let adminRegion = place.administrativeArea, !adminRegion.contains(place.locality ?? "") {
                strings.append(adminRegion)
            }
            
            name = strings.joined(separator: ", ")
            
            if let zipcode = place.postalCode {
                name += " (\(zipcode))"
            }
            
            completion(name)
        }
    }
}
