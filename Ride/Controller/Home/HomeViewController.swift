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

protocol HomeViewControllerDelegate {
    func handleMenuSliding(shouldSlide: Bool)
}

class HomeViewController: UIViewController {
    
    //MARK: Outlets
    
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var inputActivationView: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var actionButton: UIButton!
    
    //MARK: Properties
    
    private let tableView = UITableView()
    private let locationManger = LocationManager.shared.locationManager
    private let locationInputView = LocationInputView()
    private let rideActionView = RideActionView()
    private var searchResults : [MKPlacemark] = []
    private var savedLocations = [MKPlacemark]()
    private var actionButtonState = ActionButtonState.menu
    private var route: MKRoute?
    private var trip: Trip?
    var delegate : HomeViewControllerDelegate?
    
    var user : User? {
        didSet{
            guard let user = user else {return}
            self.locationInputView.userNameLabel.text = user.name
            self.configureUserType()
        }
    }
    
    var isMenuOpen = false {
        didSet{
            overlayView.isHidden = !isMenuOpen
        }
    }
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        configureUI()
    }
    
    //MARK: Configuring UI
    
    private func configureUI() {
        enableLocationServices()
        configureMapView()
        configureTableView()
        inputActivationView.alpha = 0
        overlayView.isHidden = true
        inputActivationView.addShadow()
        rideActionView.addShadow()
        map.delegate = self
        rideActionView.delegate = self
        
    }
    
    func configureMapView() {
        map.showsUserLocation = true
        map.userTrackingMode = .follow
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.locationCellNIB, bundle: nil), forCellReuseIdentifier: K.locationReusableCell)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        let height = view.frame.height - 200
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
//        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 200)
        locationInputView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        locationInputView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        locationInputView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        locationInputView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        locationInputView.translatesAutoresizingMaskIntoConstraints = false
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5,
                       animations: {self.locationInputView.alpha = 1
                       }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = 200
            })
        }
        self.locationInputView.destinationTextField.becomeFirstResponder()
    }
    
    //MARK: Actions
    
    @IBAction func chooseLocation(_ sender: UITapGestureRecognizer) {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        switch actionButtonState {
        case .backButton:
            dismissRideMode()
        case .menu:
            isMenuOpen = !isMenuOpen
            delegate?.handleMenuSliding(shouldSlide: isMenuOpen)
        }
    }
    
    @IBAction func tapOverlayView(_ sender: UITapGestureRecognizer) {
        if !overlayView.isHidden {
            isMenuOpen = !isMenuOpen
            delegate?.handleMenuSliding(shouldSlide: isMenuOpen)
        }
    }
    
    //MARK: Helpers
    
    func configureUserType() {
        guard let user = user else {return}
        if user.userType == .passenger {
            UIView.animate(withDuration: 2) {
                self.inputActivationView.alpha = 1
            }
            getNearbyDrivers()
            observeCurrentTrip()
            configureSavedUserLocation()
        } else {
            observeTrips()
        }
        
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
    
    func presentRideActionView(_ present: Bool, withConfig config: RideActionViewConfig = .requestTrip, otherUser: User? = nil) {
        if present {
            view.addSubview(rideActionView)
            rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)
            UIView.animate(withDuration: 0.3, animations: {
                if let user = otherUser {
                    self.rideActionView.otherUser = user
                }
                self.rideActionView.config = config
                self.rideActionView.frame.origin.y = self.view.frame.height - 300
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.rideActionView.frame.origin.y = self.view.frame.height
            })
            rideActionView.removeFromSuperview()
        }
    }
    
    func dismissRideMode(isDriver: Bool = false) {
        removeAnnotationsAndOverlays()
        map.showAnnotations(map.annotations, animated: true)
        self.presentRideActionView(false)
        UIView.animate(withDuration: 0.5, animations: {
            if !isDriver{
                self.inputActivationView.alpha = 1
            }
            self.configureActionButtonState(config: .menu)
            self.centerUserLocation()
        })
    }
    
    func configureSavedUserLocation() {
        savedLocations.removeAll()
        if let homeLocation = user?.homeLocation {
            geocodeAdressString(address: homeLocation)
        }
        if let workLocation = user?.workLocation {
            geocodeAdressString(address: workLocation)
        }
    }
    
    func geocodeAdressString(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let clPlacemark = placemarks?.first else {return}
            let placemark = MKPlacemark(placemark: clPlacemark)
            self.savedLocations.append(placemark)
            self.tableView.reloadData()
        }
    }
}

//MARK:- Location Manager

extension HomeViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let trip = trip else {return}
        
        if region.identifier == AnnotationType.pickup.rawValue {
            DriverService.shared.updateTripState(trip, state: .driverArrived) { (error, ref) in
                if let error = error {
                    Helpers.alert(title: "Error", message: error.localizedDescription)
                } else {
                    self.rideActionView.config = .pickupPassenger
                }
            }
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            DriverService.shared.updateTripState(trip, state: .arrivedAtDestination) { (error, ref) in
                if let error = error {
                    Helpers.alert(title: "Error", message: error.localizedDescription)
                } else {
                    self.rideActionView.config = .endTrip
                }
            }
        }
    }
    
    func enableLocationServices() {
        locationManger?.delegate = self
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
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let user = self.user else {return}
        guard user.userType == .driver else {return}
        guard let location = userLocation.location else {return}
        DriverService.shared.updateDriverLocation(location)
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
    
    func generateRoute(toDestination destin : CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: destin)
        let destination = MKMapItem(placemark: placemark)
        
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
    
    func addAnnotationToMapAndSelectIt(forCoordinates coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        map.addAnnotation(annotation)
        map.selectAnnotation(annotation, animated: true)
    }
    
    func centerUserLocation() {
        guard let coordinates = locationManger?.location?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        map.setRegion(region, animated: true)
    }
    
    func setCustomRegion(withAnnotationType anno: AnnotationType, coordinates: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinates, radius: 20, identifier: anno.rawValue)
        locationManger?.startMonitoring(for: region)
    }
    
    func cleanMapAndGenerateRoute(to coordinates: CLLocationCoordinate2D) {
        self.addAnnotationToMapAndSelectIt(forCoordinates: coordinates)
        self.generateRoute(toDestination: coordinates)
        let annotations = self.map.annotations.filter{!$0.isKind(of: DriverAnnotation.self)}
        self.map.zoomToFit(annotations: annotations)
    }
}

//MARK:- UITableView

extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Saved Locations" : "Search Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? savedLocations.count : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.locationReusableCell, for: indexPath) as! LocationCell
        if indexPath.section == 0 {
            cell.setupCellWithValues(placeMark: savedLocations[indexPath.row])
        } else if indexPath.section == 1 {
            cell.setupCellWithValues(placeMark: searchResults[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var placeMark = MKPlacemark()
        if indexPath.section == 0 {
            placeMark = self.savedLocations[indexPath.row]
        } else if indexPath.section == 1 {
            placeMark = self.searchResults[indexPath.row]
        }
        generateRoute(toDestination: placeMark.coordinate)
        dimissLocationInputView { _ in
            self.cleanMapAndGenerateRoute(to: placeMark.coordinate)
            self.configureActionButtonState(config: .backButton)
            self.presentRideActionView(true, withConfig: .requestTrip)
            self.rideActionView.destinationNameLabel.text = placeMark.name
            self.rideActionView.destinationAddressLabel.text = placeMark.address
            self.rideActionView.location = placeMark.coordinate
        }
    }
}

//MARK:- LocationInputViewDelegate

extension HomeViewController: LocationInputViewDelegate{
    func search(query: String) {
        searchBy(query: query) { (placeMarks) in
            self.searchResults = placeMarks
            self.tableView.reloadData()
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

//MARK:- RideActionViewDelegate

extension HomeViewController: RideActionViewDelegate {

    //MARK: Passenger Delegate Functions
    
    func uploadTrip(destination: CLLocationCoordinate2D?) {
        guard let pickupCoordinates = locationManger?.location?.coordinate else {return}
        guard let destination = destination else {return}
        
        PassengerService.shared.uploadTrip(pickupLocation: pickupCoordinates, destinationLocation: destination) { (error, reference) in
            if error != nil {
                Helpers.alert(title: "Error", message: error!.localizedDescription)
            } else {
                UIView.animate(withDuration: 2) {
                    self.rideActionView.frame.origin.y = self.view.frame.height
                    self.rideActionView.removeFromSuperview()
                } completion: { (_) in
                    self.shouldPresentLoadingView(true, message: "Finding you a ride...")
                }
            }
        }
    }
    
    func cancelTrip() {
        PassengerService.shared.deleteTrip { (error, ref) in
            if let error = error {
                Helpers.alert(title: "Error Canceling Trip", message: error.localizedDescription)
            } else {
                self.dismissRideMode()
            }
        }
    }
    
    //MARK: Driver Delegate Functions
    
    func pickupPassenger() {
       startTrip()
    }
    
    func endTrip() {
        guard let trip = trip else {return}
        DriverService.shared.updateTripState(trip, state: .completed) { (error, ref) in
            if let error = error {
                Helpers.alert(title: "Error", message: error.localizedDescription)
            } else {
                self.dismissRideMode(isDriver: true)
            }
        }
    }
}

//MARK:- PickupControllerDelegate

extension HomeViewController: PickupControllerDelegate {
    func didAcceptTrip(trip: Trip) {
        if trip.pickupCoordinates != nil {
            self.trip = trip
            addAnnotationToMapAndSelectIt(forCoordinates: trip.destinationCoordinates)
            
            generateRoute(toDestination: trip.pickupCoordinates)
            map.zoomToFit(annotations: map.annotations)
            setCustomRegion(withAnnotationType: .pickup, coordinates: trip.pickupCoordinates)
            
            self.dismiss(animated: true, completion: {
                guard let uid = trip.passengerUID else {return}
                Service.shared.fetchUserData(uid: uid) { (passenger) in
                    self.presentRideActionView(true, withConfig: .tripAccepted, otherUser: passenger)
                }
            })
        }
        observeDeletedTrips(trip)
    }
    
    func observeDeletedTrips(_ trip: Trip) {
        DriverService.shared.observeDeletedTrips(trip: trip) {
            self.dismissRideMode(isDriver: true)
            self.trip = nil
            Helpers.alert(title: "Sorry", message: "Passenger canceled the trip")
        }
    }
}

//MARK:- Apis Calls

extension HomeViewController {
    
    //MARK: Passenger APIs

    func getNearbyDrivers() {
        guard let location = self.locationManger?.location else {
            return
        }
        PassengerService.shared.fetchNearbyDrivers(completion: {
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
    
    func observeCurrentTrip() {
        PassengerService.shared.observeCurrentTrip { trip in
            guard let uid = trip.driverUID else {return}
            switch trip.tripState {
            case .requested:
                break
            case .accepted:
                var annotations = [MKAnnotation]()
                self.map.annotations.forEach { (annotation) in
                    if let anno = annotation as? DriverAnnotation {
                        if anno.uid == trip.driverUID {
                            annotations.append(anno)
                        }
                    }
                    if let userAnno = annotation as? MKUserLocation {
                        annotations.append(userAnno)
                    }
                }
                self.removeAnnotationsAndOverlays()
                self.map.showAnnotations(annotations, animated: true)
                self.map.zoomToFit(annotations: annotations)
                Service.shared.fetchUserData(uid: uid) { (driver) in
                    self.shouldPresentLoadingView(false)
                    self.presentRideActionView(true, withConfig: .tripAccepted, otherUser: driver)
                    self.actionButton.isHidden = true
                }
            case .driverArrived:
                self.rideActionView.config = .pickupPassenger
            case .inProgress:
                self.rideActionView.config = .tripInProgress
            case .arrivedAtDestination:
                self.rideActionView.config = .endTrip
            case .completed:
                self.deleteTrip()
            default:
                break
            }
        }
    }
    
    func deleteTrip() {
        PassengerService.shared.deleteTrip { (error, ref) in
            if let error = error {
                Helpers.alert(title: "Error Ending Trip", message: error.localizedDescription)
            } else {
                self.dismissRideMode()
                Helpers.alert(title: "Trip Completed", message: "We hope you enjoyed your trip with us")
                self.actionButton.isHidden = false
            }
        }
    }
    
    //MARK: Driver APIs

    func observeTrips() {
        DriverService.shared.observeTrips { (trip) in
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PickupControllerViewController") as? PickupControllerViewController else {return}
                vc.modalPresentationStyle = .fullScreen
            vc.trip = trip
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
   
    func startTrip() {
        guard let trip = trip else {return}
        DriverService.shared.updateTripState(trip, state: .inProgress) { (error, ref) in
            if let error = error {
                Helpers.alert(title: "Error", message: error.localizedDescription)
            } else {
                self.rideActionView.config = .tripInProgress
                self.removeAnnotationsAndOverlays()
                self.cleanMapAndGenerateRoute(to: trip.destinationCoordinates)
                self.setCustomRegion(withAnnotationType: .destination, coordinates: trip.destinationCoordinates)
            }
        }
    }
}


