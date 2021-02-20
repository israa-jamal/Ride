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

enum ActionButtonState {
    case menu
    case backButton
}

class HomeViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var inputActivationView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var actionButton: UIButton!
    
    //MARK: Properties
    
    private let tableView = UITableView()
    private let locationManger = LocationManager.shared.locationManager
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private var searchResults : [MKPlacemark] = []
    private var actionButtonState = ActionButtonState.menu
    private var route: MKRoute?
    
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
        configureRideActionView()
        inputActivationView.alpha = 0
        inputActivationView.addShadow()
        rideActionView.addShadow()
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
    
    func configureRideActionView() {
        view.addSubview(rideActionView)
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)
    }
    
    //MARK: Actions
    
    @IBAction func chooseLocation(_ sender: UITapGestureRecognizer) {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        switch actionButtonState {
        case .backButton:
            removeAnnotationsAndOverlays()
            map.showAnnotations(map.annotations, animated: true)
            self.presentRideActionView(false)
            UIView.animate(withDuration: 0.5, animations: {
                self.inputActivationView.alpha = 1
                self.configureActionButtonState(config: .menu)
            })
        case .menu:
            print("")
        }
    }
    
    //MARK: Helpers
    
    func configure() {
        configureUI()
        getUserData()
        getNearbyDrivers()
    }
    
    func configureActionButtonState(config: ActionButtonState) {
        switch config {
        case .menu:
            self.actionButtonState = .menu
            self.actionButton.setImage(UIImage(named: K.menuImage), for: .normal)
        case .backButton:
            self.actionButtonState = .backButton
            self.actionButton.setImage(UIImage(named: K.backImage), for: .normal)
        }
    }
    
    func dimissLocationInputView(completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    func presentRideActionView(_ present: Bool) {
        if present {
            UIView.animate(withDuration: 0.3, animations: {
                self.rideActionView.frame.origin.y = self.view.frame.height - 300
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.rideActionView.frame.origin.y = self.view.frame.height
            })
        }
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
        dimissLocationInputView(completion: {
            _ in
            UIView.animate(withDuration: 0.7, animations: {
                self.inputActivationView.alpha = 1
            })
        })
    }
    
}

//MARK:- MAP

extension HomeViewController :  MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: K.driverAnnotationReusableCell)
            var image = #imageLiteral(resourceName: "car")
            image = image.mask(with: .white)
            view.image = image
            view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            view.layer.cornerRadius = 15
            view.layer.borderWidth = 3
            view.layer.borderColor = UIColor.white.cgColor
            view.frame.size = CGSize(width: 30, height: 30)
            return view
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyLine = route.polyline
            let line = MKPolylineRenderer(polyline: polyLine)
            line.strokeColor = UIColor(named: K.darkBlueColor)
            line.lineWidth = 4
            return line
        }
        return MKOverlayRenderer()
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
    
    func generateRoute(toDestination destination : MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else {return}
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            self.map.addOverlay(polyline)
        }
    }
    
    func removeAnnotationsAndOverlays() {
        map.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                map.removeAnnotation(anno)
            }
        }
        if map.overlays.count > 0 {
            map.removeOverlays(map.overlays)
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
        if indexPath.section == 1 {
            let placeMark = self.searchResults[indexPath.row]
            let destination = MKMapItem(placemark: placeMark)
            generateRoute(toDestination: destination)
            dimissLocationInputView { _ in
                let annotation = MKPointAnnotation()
                annotation.coordinate = placeMark.coordinate
                self.map.addAnnotation(annotation)
                self.map.selectAnnotation(annotation, animated: true)
                self.configureActionButtonState(config: .backButton)
                let annotations = self.map.annotations.filter{!$0.isKind(of: DriverAnnotation.self)}
                self.map.zoomToFit(annotations: annotations)
                self.presentRideActionView(true)
                self.rideActionView.destinationNameLabel.text = placeMark.name
                self.rideActionView.destinationAddressLabel.text = placeMark.address
            }
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
