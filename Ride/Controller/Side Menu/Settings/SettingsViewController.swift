//
//  SettingsViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 06/04/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func configureTableView() {
        tableView.register(UINib(nibName: "MenuHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "MenuHeaderView")
        tableView.register(UINib(nibName: K.locationCellNIB, bundle: nil), forCellReuseIdentifier: K.locationReusableCell)
    }
    
    func configureNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.barStyle = .black
    navigationItem.title = "Settings"
        navigationController?.navigationBar.tintColor = K.background
        navigationController?.navigationBar.backgroundColor = K.background
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleDismiss))
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return LocationType.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.locationReusableCell, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            guard let type = LocationType(rawValue: indexPath.row) else { return cell }
            cell.setupSettingsCellWithType(type)
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MenuHeaderView") as! MenuHeaderView
            if let user = user {
                header.user = user
            }
            header.editable = true
            return header
        }
        let header = UIView()
        header.backgroundColor = K.background
        let title = UILabel()
        title.textColor = .white
        title.font = UIFont.systemFont(ofSize: 16)
        title.text = "Favorites"
        header.addSubview(title)
        title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16).isActive = true
        title.centerY(inView: header)
        return header
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section != 0 {
            return UIView()
        }
        return nil
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 10
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 100
        }
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}



