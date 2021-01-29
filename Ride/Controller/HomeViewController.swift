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
    
    
    @IBOutlet weak var inputActivationView: UIView!
    private let locationManger = CLLocationManager()
    private let locationInputView = LocationInputView()
    @IBOutlet weak var map: MKMapView!
    private let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
        locationManger.delegate = self
        configureMapView()
        configureLocationActivationInputView()
        configureTableView()
        checkIfUserIsLogedIn()
        //map.isHidden = false
        
        signOut()
        
    }
    
    //MARK: Functionalities

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
    
    //sign out
    func signOut(){
        do{
            try Auth.auth().signOut()
        }
        catch{
            print(error)
        }
    }
    
    @IBAction func chooseLocation(_ sender: UITapGestureRecognizer) {
        //show location input view once inputActivationView is clicked
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    
    //MARK: Configuring UI
    
    func configureMapView(){
        //showing user moving location
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        
    }
    func configureLocationInputView(){
        //showing the location input view in the screen
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5,
                       animations: {self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                //show animated tableView with locationInputView
                self.tableView.frame.origin.y = 200
            })
        }
        
    }
    func configureLocationActivationInputView(){
        //show the location input on screen
        inputActivationView.addShadow()
        UIView.animate(withDuration: 2){
            self.inputActivationView.alpha = 1
        }
    }
    func configureTableView(){
        //adding tableView to the screen
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "ReusableLocationCell")
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        let height = view.frame.height - 200
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)

    }
}


//MARK:- Location Manager

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

//MARK:- LocationInputViewDelegate

extension HomeViewController: LocationInputViewDelegate{
    // dismiss the tableView and the locationInputView once back button is pressed
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

//MARK:- TableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "test"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableLocationCell", for: indexPath) as! LocationCell
        return cell
    }
    
    
}
