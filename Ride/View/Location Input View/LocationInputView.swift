//
//  LocationInputViewController.swift
//  Ride
//
//  Created by Esraa Gamal on 10/12/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit

protocol LocationInputViewDelegate: class{
    func dismissView ()
    func search(query: String)
}

class LocationInputView: UIView {
    
    weak var delegate: LocationInputViewDelegate?
    
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentLocationTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var startDotView : UIView!
    
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
        Bundle.main.loadNibNamed("LocationInputView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        ///setup subviews
        destinationTextField.delegate = self
        startDotView.layer.cornerRadius = 6/2
        currentLocationTextField.addPlaceHolder(text: "Current Location", color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        destinationTextField.addPlaceHolder(text: "Enter a destination..", color: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
        currentLocationTextField.setPaddingPoints(8)
        destinationTextField.setPaddingPoints(8)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegate?.dismissView()
    }
}

extension LocationInputView : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else {return false}
        delegate?.search(query: query)
        return true
    }
}
