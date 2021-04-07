//
//  AddLocationViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 06/04/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit
import MapKit

protocol AddLocationDelegate {
    func didSelectLocation(locationName: String, locationValue: String, type: LocationType)
}

class AddLocationViewController: UITableViewController {

    private let searchBar = UISearchBar()
    private let searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private let type : LocationType
    private let location : CLLocation
    var delegate: AddLocationDelegate?
    
    init(type: LocationType, location: CLLocation) {
        self.location = location
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureSearchBar()
        configureTableView()
        configureSearchCompleter()
    }

    func configureSearchBar() {
        searchBar.becomeFirstResponder()
        searchBar.sizeToFit()
        searchBar.delegate = self
//        searchBar.searchTextField.textColor = .white
        searchBar.tintColor = .white
        navigationItem.titleView = searchBar
    }
    
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 50
        
        tableView.addShadow()
    }
    
    func configureSearchCompleter() {
        searchCompleter.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200000, longitudinalMeters: 200000)
        searchCompleter.delegate = self
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.tintColor = K.background
//        navigationController?.navigationBar.backgroundColor =
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.barTintColor = K.background

    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- UITableView

extension AddLocationViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let result = searchResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectLocation(locationName: searchResults[indexPath.row].title, locationValue: searchResults[indexPath.row].subtitle, type: type)
    }
}
//MARK:- UISearchBar

extension AddLocationViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
    }
}

//MARK:- UISearchCompleter

extension AddLocationViewController : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
        tableView.reloadData()
    }
}
