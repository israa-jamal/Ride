//
//  CircularPulsingView.swift
//  Ride
//
//  Created by Esraa Gamal on 07/04/2021.
//  Copyright © 2021 Esraa Gamal. All rights reserved.
//

import UIKit

class CircularPulsingView: UIView {
    
    @IBOutlet weak var contentView : UIView!

    var progressLayer : CAShapeLayer!
    var pulsingLayer: CAShapeLayer!
    var trackLayer: CAShapeLayer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCircularLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCircularLayer()
    }
 
    
    private func configureCircularLayer() {
        Bundle.main.loadNibNamed("CircularPulsingView", owner: self, options: nil)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleWidth,
            UIView.AutoresizingMask.flexibleHeight
              ]
        addSubview(contentView)
        pulsingLayer = circleShapeLayer(strokeColor: .clear, fillColor: K.blueColor)
        contentView.layer.addSublayer(pulsingLayer)
        
        trackLayer = circleShapeLayer(strokeColor: .clear, fillColor: .clear)
        contentView.layer.addSublayer(trackLayer)
        trackLayer.strokeEnd = 1
        
        progressLayer = circleShapeLayer(strokeColor: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), fillColor: .clear)
        contentView.layer.addSublayer(progressLayer)
        progressLayer.strokeEnd = 1
    }
    
    private func circleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let center = CGPoint(x: 0, y: 0)
        let circularPath = UIBezierPath(arcCenter: center, radius: self.frame.width / 2.5, startAngle: -(CGFloat.pi / 2), endAngle: 1.5 * CGFloat.pi , clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.fillColor = fillColor.cgColor
        layer.lineWidth = 12
        layer.lineCap = .round
        layer.position = contentView.center
        return layer
    }
    
    func animatingPulsinLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.fromValue = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        pulsingLayer.add(animation, forKey: "pulsing")
    }
    
    func setProgressWithAnimation(duration: TimeInterval, value: Float, completion: @escaping()->Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.toValue = value
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateProgress")
        CATransaction.commit()
    }
}
