//
//  MapManager.swift
//  SoulBar
//
//  Created by 陳建綸 on 2022/11/1.
//

import Foundation
import MapKit

class MapManager {
    
    static let sharedInstance = MapManager()
    
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }

}
