//
//  Extensions.swift
//  Ride
//
//  Created by Esraa Gamal on 10/13/20.
//  Copyright © 2020 Esraa Gamal. All rights reserved.
//

import UIKit
import MapKit

//MARK: - UIView

extension UIView{
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
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
    
    func addPlaceHolder(text: String, color: UIColor) {
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor : color ])
    }
    
    func setPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
        self.rightView = paddingView
        self.rightViewMode = .always
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
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = LoadingIndicatorView()
            loadingView.frame = view.frame
            loadingView.tag = 1212
            view.addSubview(loadingView)
            loadingView.messageLabel.text = message
            loadingView.indicatorView.startAnimating()
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { (subview) in
                if subview.tag == 1212 {
                    UIView.animate(withDuration: 0.3) {
                        subview.alpha = 0
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}
//MARK: - MKPlaceMark

extension MKPlacemark {
    var address : String? {
        get {
            guard let subThroughFare = subThoroughfare else {return nil}
            guard let throughFare = thoroughfare else {return nil}
            guard let locality = locality else {return nil}
            guard let adminArea = administrativeArea else {return nil}
            return "\(subThroughFare) \(throughFare), \(locality), \(adminArea) "
        }
    }
}

//MARK: - MKMapView

extension MKMapView {
    func zoomToFit(annotations : [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { (annotation) in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            zoomRect = zoomRect.union(pointRect)
        }
        let insets = UIEdgeInsets(top: 75, left: 75, bottom: 375, right: 75)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
}
//MARK: - UIImage

extension UIImage {
    
    public func mask(with color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        color.setFill()
        self.draw(in: rect)
        
        context.setBlendMode(.sourceIn)
        context.fill(rect)
        
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resultImage
    }
}

