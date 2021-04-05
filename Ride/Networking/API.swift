//
//  API.swift
//  Ride
//
//  Created by Esraa Gamal on 29/01/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import Foundation
import Firebase

struct API {
    
    static func isUserLoggedIn() -> Bool {
        if Auth.auth().currentUser?.uid == nil {
            return false
        } else {
            return true
        }
    }
    
    static func signOut(completion: @escaping()->()) {
        do {
            try Auth.auth().signOut()
            completion()
        }
        catch {
            Helpers.alert(title: "There was an error logging you out", message: error.localizedDescription)
        }
    }
    
}
