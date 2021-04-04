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
let tripsRef = dbRef.child("trips")

struct Service {
    
    static let shared = Service()
    
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
    
    func uploadTrip(pickupLocation : CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let pickupArray = [pickupLocation.latitude, pickupLocation.longitude]
        let destinationArray = [destinationLocation.latitude, destinationLocation.longitude]
        let values = ["pickupCoordinates" : pickupArray, "destinationCoordinates" : destinationArray, "state" : TripState.requested.rawValue] as [String : Any]
        tripsRef.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func observeTrips(completion: @escaping(Trip) -> Void) {
        tripsRef.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let trip = Trip(passengerUID: snapshot.key.description, dictionary: dictionary)
            if trip.tripState == .requested {
                completion(trip)
            }
        }
    }
    
    func observeDeletedTrips(trip: Trip, completion: @escaping() -> Void) {
        tripsRef.child(trip.passengerUID).observeSingleEvent(of: .childRemoved, with: { _ in
            completion()
        })
    }
    
    func acceptTrip(trip: Trip, completion: @escaping(Error?, Trip) -> Void) {
        guard let driverUID = Auth.auth().currentUser?.uid else {return}
        let values = ["driverUID": driverUID, "state": TripState.accepted.rawValue] as [String : Any]
        tripsRef.child(trip.passengerUID).updateChildValues(values) { (error, ref) in
            ref.observeSingleEvent(of: .value) { (snapshot) in
                let dictionary = snapshot.value as? [String: Any] ?? [:]
                let trip = Trip(passengerUID: snapshot.key.description, dictionary: dictionary)
                completion(error, trip)
            }
        }
    }
    
    func observeCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        tripsRef.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            let trip = Trip(passengerUID: snapshot.key.description, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func deleteTrip(completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        tripsRef.child(uid).removeValue(completionBlock: completion)
    }
    
    func updateDriverLocation(_ location : CLLocation) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let geoFire = GeoFire(firebaseRef: driversLocationRef)
        geoFire.setLocation(location, forKey: uid)
    }
    
    func updateTripState(_ trip: Trip, state: TripState, completion: @escaping (Error?, DatabaseReference) -> Void) {
        tripsRef.child(trip.passengerUID).child("state").setValue(state.rawValue, withCompletionBlock: completion)
        if trip.tripState == TripState.completed {
            tripsRef.child(trip.passengerUID).removeAllObservers()
        }
    }
}
