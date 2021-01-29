//
//  Helpers.swift
//  Ride
//
//  Created by Esraa Gamal on 29/01/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import Foundation
import LKAlertController

class Helpers {
  
    static func alert(title: String, message: String) {
        Alert(title: title, message: message)
            .addAction("OK")
            .show()
    }
}
