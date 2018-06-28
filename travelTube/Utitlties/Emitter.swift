//
//  Emitter.swift
//  travelTube
//
//  Created by 吳登秝 on 2018/6/27.
//  Copyright © 2018年 DavidWu. All rights reserved.
//

import Foundation

class Emmiter {
    static func get(with image: UIImage) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterShape = kCAEmitterLayerLine
        emitter.emitterCells = generateEmitterCells(with: image)
        return emitter
    }

    static func generateEmitterCells(with image: UIImage) -> [CAEmitterCell] {
        var cells = [CAEmitterCell]()

        let cell = CAEmitterCell()
        cell.contents = image.cgImage
        cell.birthRate = 0.5
        cell.lifetime = 100
        cell.velocity = CGFloat(25)
        cell.emissionRange = (30 * (.pi/180))
        cell.scale = 0.1
        cell.scaleRange = 0.1

        cells.append(cell)

        return cells
    }
}
