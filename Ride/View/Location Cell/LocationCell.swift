//
//  LocationCell.swift
//  Ride
//
//  Created by Esraa Gamal on 10/13/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
    }
    
    func setupCellWithValues(placeMark : MKPlacemark) {
        locationLabel.text = placeMark.name
        addressLabel.text = placeMark.address
    }
    func setupSettingsCellWithType(_ type: LocationType) {
        locationLabel.text = type.description
        addressLabel.text = type.subtitle
    }
}
