//
//  Enums.swift
//  Ride
//
//  Created by Esraa Gamal on 01/04/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import Foundation

enum ActionButtonState {
    case menu
    case backButton
}

enum UserType : Int {
    case passenger
    case driver
}
enum TripState : Int{
    case requested
    case accepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case completed
}

enum RideActionViewConfig{
    case requestTrip
    case pickupPassenger
    case tripAccepted
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestTrip
    }
}

enum ActionButtonConfig : CustomStringConvertible{
    case request
    case cancel
    case pickup
    case getDirection
    case dropOff
    var description: String {
        switch self {
        case .request:
            return "CONFIRM RIDEX"
        case .cancel:
            return "CANCEL RIDE"
        case .pickup:
            return "PICKUP PASSENGER"
        case .getDirection:
            return "GET DIRECTIONS"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    init() {
        self = .request
    }
}
enum AnnotationType : String {
    case pickup
    case destination
}
