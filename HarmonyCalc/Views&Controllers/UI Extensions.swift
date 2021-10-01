//
//  Gradients.swift
//  HarmonyCalc
//
//  Created by ASM on 5/5/18.
//  Copyright © 2018 ASM. All rights reserved.
//

import UIKit

extension UIView {
    func addGradientBackground(colorOne: UIColor, colorTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = nil
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

struct Colors {
    static let blueBlue = UIColor(red: 64/255, green: 124/255, blue: 200/255, alpha: 1.0)
    static let heavy = UIColor(red: 207/255, green: 217/255, blue: 223/255, alpha: 0.5)
    static let rain = UIColor(red: 226/255, green: 235/255, blue: 240/255, alpha: 0.5)
}


