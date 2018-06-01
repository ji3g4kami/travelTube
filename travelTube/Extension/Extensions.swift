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
