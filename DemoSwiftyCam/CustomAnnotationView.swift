//
//  CustomAnnotationView.swift
//  DemoSwiftyCam
//
//  Created by Jordan Russell Weatherford on 6/17/17.
//  Copyright © 2017 Cappsule. All rights reserved.
//

import UIKit
import HDAugmentedReality

//1
protocol CustomAnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView)
}

//2
class CustomAnnotationView: ARAnnotationView {
    //3
    var titleLabel: UILabel?
    var distanceLabel: UILabel?
    var delegate: AnnotationViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        loadUI()
    }
    
    //4
    func loadUI() {
        titleLabel?.removeFromSuperview()
        distanceLabel?.removeFromSuperview()
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: self.frame.size.width, height: 30))
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        label.textColor = UIColor.white
        self.addSubview(label)
        self.titleLabel = label
        
        distanceLabel = UILabel(frame: CGRect(x: 10, y: 30, width: self.frame.size.width, height: 20))
        distanceLabel?.backgroundColor = UIColor(white: 0.3, alpha: 0.7)
        distanceLabel?.textColor = UIColor.green
        distanceLabel?.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(distanceLabel!)
        
        if let annotation = annotation as? Place {
            titleLabel?.text = annotation.placeName
            distanceLabel?.text = String(format: "%.2f km", annotation.distanceFromUser / 1000)
        }
    }
}