//
//  HomeViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 10/12/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class HomeViewController: UIViewController {

    private let locationManger = CLLocationManager()
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        locationManger.delegate = self
        configureMapView()
//       map.isHidden = true
// signOut()
        checkIfUserIsLogedIn()
        // Do any additional setup after loading the view.
    }
    
    func configureMapView(){
        map.showsUserLocation = true
        map.userTrackingMode = .follow
    }
    
    func checkIfUserIsLogedIn(){
       if Auth.auth().currentUser?.uid == nil{
        DispatchQueue.main.async {
           
           self.performSegue(withIdentifier: "goToLogin", sender: self)
              
//            self.view.window?.rootViewController = LoginViewController()
//            self.view.window?.makeKeyAndVisible()

//             self.present(navigationController, animated: true, completion: nil)
        }
        print("debug: the user is signed out")
        }
       else{
        map.isHidden = false
        }
    }
    
    func signOut(){
        do{
            print("the user is signed out")
         try Auth.auth().signOut()
        }
    catch{
        print(error)
        }
    }

}
extension HomeViewController: CLLocationManagerDelegate{
    func enableLocationServices(){
        switch CLLocationManager.authorizationStatus() {
        case .denied , .restricted , .notDetermined :
            print("Location is not accessed")
            locationManger.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            print("Location is authorized")
            locationManger.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManger.startUpdatingLocation()
            locationManger.desiredAccuracy = kCLLocationAccuracyBest
        @unknown default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManger.requestAlwaysAuthorization()

        }
    }
}
