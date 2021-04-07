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
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var initialLabel: UILabel!

    var user : User? {
        didSet{
            nameLabel.text = user?.name
            emailLabel.text = user?.email
            guard let user = user else {return}
            initialLabel.text = String(user.name.prefix(1))
        }
    }
    var editable = false {
        didSet{
            mainView.backgroundColor = .white
            backView.backgroundColor = .white
            nameLabel.textColor = .black
            emailLabel.textColor = .darkGray
            mainView.centerY(inView: backView)
            if topConstraint != nil {
                topConstraint.isActive = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilePhotoImageView.layer.cornerRadius = 64/2
    }
    
}
