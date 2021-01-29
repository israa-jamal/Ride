//
//  Extensions.swift
//  Ride
//
//  Created by Esraa Gamal on 10/13/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit

//MARK: - UIView

extension UIView{
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                  left: NSLayoutXAxisAnchor? = nil,
                  bottom: NSLayoutYAxisAnchor? = nil,
                  right: NSLayoutXAxisAnchor? = nil,
                  paddingTop: CGFloat = 0,
                  paddingLeft: CGFloat = 0,
                  paddingBottom: CGFloat = 0,
                  paddingRight: CGFloat = 0,
                  width: CGFloat? = nil,
                  height: CGFloat? = nil) {
          
          translatesAutoresizingMaskIntoConstraints = false
          
          if let top = top {
              topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
          }
          
          if let left = left {
              leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
          }
          
          if let bottom = bottom {
              bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
          }
          
          if let right = right {
              rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
          }
          
          if let width = width {
              widthAnchor.constraint(equalToConstant: width).isActive = true
          }
          
          if let height = height {
              heightAnchor.constraint(equalToConstant: height).isActive = true
          }
      }
    func centerX(inView view: UIView) {
           translatesAutoresizingMaskIntoConstraints = false
           centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
       }
       
       func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                    paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
           
           translatesAutoresizingMaskIntoConstraints = false
           centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
           
           if let left = leftAnchor {
               anchor(left: left, paddingLeft: paddingLeft)
           }
       }
    func setDimensions(height: CGFloat, width: CGFloat) {
           translatesAutoresizingMaskIntoConstraints = false
           heightAnchor.constraint(equalToConstant: height).isActive = true
           widthAnchor.constraint(equalToConstant: width).isActive = true
       }
    func addShadow() {
          layer.shadowColor = UIColor.black.cgColor
          layer.shadowOpacity = 0.55
          layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
          layer.masksToBounds = false
      }
}

//MARK: - UITextField

extension UITextField {
    
    func addPlaceHolder(text: String){
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.509620616) ])
    }
    
}


//MARK: - UIViewController

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}