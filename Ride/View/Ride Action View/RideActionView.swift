//
//  RideActionView.swift
//  Ride
//
//  Created by Esraa Gamal on 20/02/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit

class RideActionView : UIView {
    
    
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var xView : UIView!
    @IBOutlet weak var destinationNameLabel : UILabel!
    @IBOutlet weak var destinationAddressLabel: UILabel!
    @IBOutlet weak var requestRideButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    private func configureUI() {
        
        ///setup contentView
        Bundle.main.loadNibNamed("RideActionView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        ///setup subviews
        xView.layer.cornerRadius = 30
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
    }
}


