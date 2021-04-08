//
//  User.swift
//  Ride
//
//  Created by Esraa Gamal on 29/01/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import Foundation
import CoreLocation

struct User {
    let uid : String
    let name : String
    let email : String
    var userType : UserType!
    var location : CLLocation?
    var homeLocation: String?
    var workLocation: String?
    var home: String?
    var work: String?
    
    init(uid: String, data: [String: Any]) {
        self.name = data["fullName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.uid = uid
        if let index = data["accountType"] as? Int {
            self.userType = UserType(rawValue: index)
        }
        if let home = data["Home"] as? String, let homeLocation = data["homeLocation"] as? String {
            self.home = home
            self.homeLocation = homeLocation

        }
        if let work = data["Work"] as? String, let workLocation = data["workLocation"] as? String {
            self.work = work
            self.workLocation = workLocation
        }
      
    }
}
