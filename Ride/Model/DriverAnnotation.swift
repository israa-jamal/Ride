//
//  DriverAnnotation.swift
//  Ride
//
//  Created by Esraa Gamal on 20/02/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import Foundation
import MapKit

class DriverAnnotation : NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uid : String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(withCoordinate coordinate : CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
    }
}
