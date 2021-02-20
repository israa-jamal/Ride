//
//  Service.swift
//  Ride
//
//  Created by Esraa Gamal on 29/01/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

let dbRef = Database.database().reference()
let usersRef = dbRef.child("users")
let driversLocationRef = dbRef.child("drivers-locations")

struct Service {
    
    static let shared = Service()
    let currentUID = Auth.auth().currentUser?.uid
    
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
            usersRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                guard let result = snapshot.value as? [String: Any] else { return }
                let UID = snapshot.key
                let user = User(uid: UID, data: result)
                completion(user)
            }
        
    }
    
    func fetchNearbyDrivers(completion: @escaping(User) -> Void, location : CLLocation) {
        let geoFire = GeoFire(firebaseRef: driversLocationRef)
        driversLocationRef.observe(.value) { (snapshot) in
            geoFire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, driverLocation) in
                fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = driverLocation
                    completion(driver)
                }
            })
        }
    }
}
