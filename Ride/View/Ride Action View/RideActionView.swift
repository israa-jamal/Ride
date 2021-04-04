//
//  RideActionView.swift
//  Ride
//
//  Created by Esraa Gamal on 20/02/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit
import CoreLocation

protocol RideActionViewDelegate {
    func uploadTrip(destination : CLLocationCoordinate2D?)
    func cancelTrip()
    func pickupPassenger()
    func endTrip()
}

class RideActionView : UIView {
    
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var xView : UIView!
    @IBOutlet weak var destinationNameLabel : UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var requestRideButton: UIButton!
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var tripDescription: UILabel!

    var delegate : RideActionViewDelegate?
    var location : CLLocationCoordinate2D?
    var buttonConfig = ActionButtonConfig()
    var otherUser : User?
    var trip : Trip?
    var config = RideActionViewConfig() {
        didSet {
            configureMainView()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    private func configureUI() {
        
        ///setup contentView
        Bundle.main.loadNibNamed("RideActionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        ///setup subviews
        xView.layer.cornerRadius = 30
    }
    
    private func configureMainView() {
        self.requestRideButton.isEnabled = true
        self.requestRideButton.alpha = 1
        if let type = otherUser?.userType {
            switch type {
            case .driver:
                switch config {
                case .requestTrip:
                    self.buttonConfig = .request
                    logoLabel.text = "X"
                    tripDescription.text = "RIDE X"
                case .pickupPassenger:
                    destinationNameLabel.text = "Driver Has Arrived To Your Location"
                    destinationAddressLabel.text = "Please Meet Driver At Pickup Location"
                case .tripAccepted:
                    self.buttonConfig = .cancel
                    destinationNameLabel.text = "Driver's On His Way"
                    logoLabel.text = "\(otherUser?.name.first ?? "X")"
                    tripDescription.text = otherUser?.name
                case .tripInProgress:
                    destinationNameLabel.text = "On The Route To Destination"
                    destinationAddressLabel.text = ""
                    self.buttonConfig = .cancel
                    self.requestRideButton.isEnabled = false
                    self.requestRideButton.alpha = 0.8
                case .endTrip:
                    destinationNameLabel.text = "Arrived At Destination"
                    self.requestRideButton.isEnabled = false
                    self.requestRideButton.alpha = 0.8
                }
            case .passenger:
                switch config {
                case .requestTrip:
                   break
                case .pickupPassenger:
                    self.buttonConfig = .pickup
                    destinationNameLabel.text = "Arrived At Passenger Location"
                case .tripAccepted:
                    destinationNameLabel.text = "The Route To Passenger"
                    self.buttonConfig = .getDirection
                    logoLabel.text = "\(otherUser?.name.first ?? "X")"
                    tripDescription.text = otherUser?.name
                case .tripInProgress:
                    destinationNameLabel.text = "On The Route To Destination"
                    self.buttonConfig = .getDirection
                case .endTrip:
                    destinationNameLabel.text = "Arrived At Destination"
                    buttonConfig = .dropOff
                }
            }
        }
        
        configureActionButton()
    }
    func configureActionButton() {
        requestRideButton.setTitle(buttonConfig.description, for: .normal)
    }
    
    @IBAction func confirmTrip(_ sender: UIButton) {
        switch buttonConfig {
        case .request:
            delegate?.uploadTrip(destination: location)
        case .cancel:
            delegate?.cancelTrip()
        case .pickup:
            delegate?.pickupPassenger()
        case .getDirection:
            break
        case .dropOff:
            delegate?.endTrip()
        }
    }
}


