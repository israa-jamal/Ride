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
    let userType : Int
    var location : CLLocation?
    
    init(uid: String, data: [String: Any]) {
        self.name = data["fullName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.userType = data["accountType"]as? Int ?? 0
        self.uid = uid
    }
}
