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

    var trip : Trip?
    var delegate : PickupControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        guard let trip = trip else {return}
        DriverService.shared.acceptTrip(trip: trip) { (error, response) in
            if error != nil{
                Helpers.alert(title: "Error", message: error?.localizedDescription ?? "Error")
            } else {
                self.delegate?.didAcceptTrip(trip: response)
            }
        }
    }
    
    func configureMapView() {
        map.layer.cornerRadius = 270 / 2
        
        guard let pickupCoordinates = trip?.pickupCoordinates else {return}
        let region = MKCoordinateRegion(center: pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
        let anno = MKPointAnnotation()
        anno.coordinate = pickupCoordinates
        map.addAnnotation(anno)
        map.selectAnnotation(anno, animated: false)
    }
}
