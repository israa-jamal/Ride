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
    private let locationManger = LocationManager.shared.locationManager
    private let locationInputView = LocationInputView()
    private var searchResults : [MKPlacemark] = []
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configure()
    }
    
    //MARK: Configuring UI
    
    private func configureUI() {
        enableLocationServices()
        configureMapView()
        configureTableView()
        inputActivationView.alpha = 0
        inputActivationView.addShadow()
        map.delegate = self
        
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
    
    //MARK: Actions
    
    @IBAction func chooseLocation(_ sender: UITapGestureRecognizer) {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    //MARK: Helpers
    
    func configure() {
        configureUI()
        getUserData()
        getNearbyDrivers()
    }
    
    func dimissLocationInputView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.5, animations: {
     self.locationInputView.alpha = 0
     self.tableView.frame.origin.y = self.view.frame.height
     self.locationInputView.removeFromSuperview()
     UIView.animate(withDuration: 0.7, animations: {self.inputActivationView.alpha = 1
     })
        }, completion: completion)
    }
}

//MARK:- Location Manager

extension HomeViewController{
    
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .denied , .restricted , .notDetermined :
            locationManger?.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            locationManger?.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManger?.startUpdatingLocation()
            locationManger?.desiredAccuracy = kCLLocationAccuracyBest
        @unknown default:
            break
        }
    }
}

//MARK:- LocationInputViewDelegate

extension HomeViewController: LocationInputViewDelegate{
    func search(query: String) {
        searchBy(query: query) { (placeMarks) in
            self.searchResults = placeMarks
            self.tableView.reloadData()
            print(placeMarks)
        }
    }
    
    func dismissView() {
        dimissLocationInputView()
    }
    
}

//MARK:- MAP

extension HomeViewController :  MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: K.driverAnnotationReusableCell)
            view.image = #imageLiteral(resourceName: "car")
            view.backgroundColor = #colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1)
            view.layer.cornerRadius = 15
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.black.cgColor
            view.frame.size = CGSize(width: 30, height: 30)
            return view
        }
        return nil
    }
    
    //MARK: Map Helpers
    
    func searchBy(query: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        request.region = map.region
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {return}
            response.mapItems.forEach { item in
                results.append(item.placemark)
            }
            completion(results)
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
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableLocationCell", for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            cell.setupCellWithValues(placeMark: searchResults[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dimissLocationInputView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.searchResults[indexPath.row].coordinate
            self.map.addAnnotation(annotation)
            self.map.selectAnnotation(annotation, animated: true)
        }
    }
}

//MARK:- Apis Calls

extension HomeViewController {
    
    func getUserData() {
        guard let uid = Service.shared.currentUID else {return}
        Service.shared.fetchUserData(uid: uid) { user in
            self.locationInputView.userNameLabel.text = user.name
        }
    }
    
    func getNearbyDrivers() {
        guard let location = self.locationManger?.location else {
            return
        }
        Service.shared.fetchNearbyDrivers(completion: {
            driver in
            guard let coordinate = driver.location?.coordinate else {return}
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            var driverIsVisible : Bool {
                return self.map.annotations.contains { (annotation) -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else {return false}
                    if driverAnnotation.uid == driver.uid {
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            if !driverIsVisible {
                self.map.addAnnotation(annotation)
            }
        }, location: location)
    }
}
