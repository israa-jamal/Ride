//
//  PickupControllerViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 21/03/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit
import MapKit

protocol PickupControllerDelegate : class {
    func didAcceptTrip(trip: Trip)
}

class PickupControllerViewController: UIViewController {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var circularView : CircularPulsingView!

    var trip : Trip?
    var delegate : PickupControllerDelegate?
    var denied = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.animateProgress()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        denyTrip()
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        denied = false
        guard let trip = trip else {return}
        DriverService.shared.acceptTrip(trip: trip) { (error, response) in
            if error != nil{
                Helpers.alert(title: "Error", message: error?.localizedDescription ?? "Error")
                self.denied = true
            } else {
                self.delegate?.didAcceptTrip(trip: response)
            }
        }
    }
    func animateProgress() {
        circularView.animatingPulsinLayer()
        circularView.setProgressWithAnimation(duration: 7, value: 0) {
            if self.denied {
                self.denyTrip()
            }
        }
    }
    func configureMapView() {
        map.layer.cornerRadius = 275 / 2
        circularView.addSubview(map)
        guard let pickupCoordinates = trip?.pickupCoordinates else {return}
        let region = MKCoordinateRegion(center: pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
        let anno = MKPointAnnotation()
        anno.coordinate = pickupCoordinates
        map.addAnnotation(anno)
        map.selectAnnotation(anno, animated: false)
    }
    
    func denyTrip() {
        guard let trip = self.trip else {return}
        DriverService.shared.updateTripState(trip, state: .denied) { (error, ref) in
            if let error = error {
                Helpers.alert(title: "Error", message: error.localizedDescription)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
