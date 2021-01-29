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
    
    //MARK: Outlets
    
    @IBOutlet weak var inputActivationView: UIView!
    @IBOutlet weak var map: MKMapView!
    
    //MARK: Properties
    
    private let tableView = UITableView()
    private let locationManger = CLLocationManager()
    private let locationInputView = LocationInputView()

    //MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        hideKeyboardWhenTappedAround()
//        checkIfUserIsLogedIn()
    }
    
    //MARK: Configuring UI
    
    private func configureUI() {
        enableLocationServices()
        locationManger.delegate = self
        configureMapView()
        configureTableView()
        inputActivationView.alpha = 0
        inputActivationView.addShadow()

        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        map.showsUserLocation = true
        map.userTrackingMode = .follow
    }
  
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "ReusableLocationCell")
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        let height = view.frame.height - 200
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5,
                       animations: {self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = 200
            })
        }
    }
    
    //MARK: Logic

    func checkIfUserIsLogedIn(){
        //if the user is already logged in go directly to the map
        if Auth.auth().currentUser?.uid == nil{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToLogin", sender: self)
                
                //self.view.window?.rootViewController = LoginViewController()
                //self.view.window?.makeKeyAndVisible()
                //self.present(navigationController, animated: true, completion: nil)
            }
            print("debug: the user is signed out")
        }
        else{
            print("debug: the user is signed in")
            //map.isHidden = false
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
        }
        catch{
            print(error)
        }
    }
    
    @IBAction func chooseLocation(_ sender: UITapGestureRecognizer) {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
}

//MARK:- Location Manager

extension HomeViewController: CLLocationManagerDelegate{
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .denied , .restricted , .notDetermined :
            locationManger.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
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

//MARK:- LocationInputViewDelegate

extension HomeViewController: LocationInputViewDelegate{
    
    func dismissLocationInputView() {
        UIView.animate(withDuration: 0.3,
                       animations: {self.locationInputView.alpha = 0
                        self.tableView.frame.origin.y = self.view.frame.height
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {self.inputActivationView.alpha = 1
                self.locationInputView.removeFromSuperview()
            })
        }
    }
    
}

//MARK:- UITableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Section 1" : "Section 2"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableLocationCell", for: indexPath) as! LocationCell
        return cell
    }

}
