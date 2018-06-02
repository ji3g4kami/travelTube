//
//  Extensions.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/5/21.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import UIKit

extension UIImageView {
    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func removeAllGestures() {
        guard let gestureRecognizers = view.gestureRecognizers else { return }
        for recognizer in gestureRecognizers {
            view.removeGestureRecognizer(recognizer)
        }
    }
}

extension Article: Equatable {
    static func == (lhs: Article, rhs: Article) -> Bool {
        return lhs.updateTime != rhs.updateTime
    }
}

extension CAGradientLayer {

    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        startPoint = CGPoint(x: 0, y: 0)
        endPoint = CGPoint(x: 0, y: 1)
    }

    func createGradientImage() -> UIImage? {

        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }

}

extension UINavigationBar {

    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 63/255, green: 143/255, blue: 246/255, alpha: 1).cgColor,
            UIColor(red: 73/255, green: 85/255, blue: 168/255, alpha: 1).cgColor,
            UIColor(red: 213/255, green: 119/255, blue: 204/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = self.bounds
        setBackgroundImage(gradientLayer.createGradientImage(), for: UIBarMetrics.default)
    }
}
