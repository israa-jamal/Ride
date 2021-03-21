//
//  User.swift
//  Ride
//
//  Created by Esraa Gamal on 29/01/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import Foundation
import CoreLocation

enum UserType : Int {
    case passenger = 0
    case driver = 1
}

struct User {
    let uid : String
    let name : String
    let email : String
    var userType : UserType!
    var location : CLLocation?

    init(uid: String, data: [String: Any]) {
        self.name = data["fullName"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.uid = uid
        if let index = data["accountType"] as? Int {
            self.userType = UserType(rawValue: index)
        }
    }
}
