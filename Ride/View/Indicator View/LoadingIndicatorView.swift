//
//  LoadingIndicatorView.swift
//  Ride
//
//  Created by Esraa Gamal on 22/03/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit

class LoadingIndicatorView: UIView {

    @IBOutlet weak var indicatorView : UIActivityIndicatorView!
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var contentView : UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    private func configureUI() {
        Bundle.main.loadNibNamed("LoadingIndicatorView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        alpha = 0
    }
}
