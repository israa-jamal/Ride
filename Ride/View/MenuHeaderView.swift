//
//  MenuHeaderView.swift
//  Ride
//
//  Created by Esraa Gamal on 05/04/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit

class MenuHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePhotoImageView: UIImageView!

    var user : User? {
        didSet{
            nameLabel.text = user?.name
            emailLabel.text = user?.email
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePhotoImageView.layer.cornerRadius = 64/2
    }
    
}
