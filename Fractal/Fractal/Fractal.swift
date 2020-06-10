//
//  Fractal.swift
//  Fractal
//
//  Created by Ildar Usmanov on 02.06.2020.
//  Copyright © 2020 Ildar Usmanov. All rights reserved.
//

import Foundation
import UIKit

struct Complex {
    var re: Double
    var im: Double

    init() {
        re = 0
        im = 0
    }
    init(re: Double, im: Double) {
        self.re = re
        self.im = im
    }
}

protocol FractalDelegate: class {
    func updateUIImage(uiimage: UIImage?)
}

class Fractal {
    private var formula: (Complex, Int) -> Int = {_,_ in return 0}
    private var imageFromArray: ImageFromColorArray
    private var min: Complex
    private var max = Complex()
    var maxIteration = 25
    private var height: Double
    private var width: Double
    private let len: Int
    weak var delegate: FractalDelegate?
    private let iterationQueue = DispatchQueue.global(qos: .userInteractive)
    private let fractalQueue = DispatchQueue(label: "FractalQueue", qos: .userInitiated)

    init(_ size: CGSize) {
        height = Double(size.height)
        width = Double(size.width)
        min = Complex(re: -2.0, im: -1.0)
        max.re = 2.0
        max.im = min.im + (max.re - min.re) * height / width
        len = Int(width * height)

        imageFromArray = ImageFromColorArray(frame: size)
        
        formula = mandelbrot
    }
    private func getColor(_ t: Double) -> Rgb {
        return Rgb(r: UInt8(9 * (1 - t) * pow(t, 3) * 255),
                   g: UInt8(15 * pow((1 - t), 2) * pow(t, 2) * 255),
                   b: UInt8(8.5 * pow((1 - t), 3) * t * 255))
    }

    private func mandelbrot(_ c: Complex, _ maxIter: Int) -> Int {
        var iteration = 0;
        var z = c
        while (pow(z.re, 2.0) + pow(z.im, 2.0) <= 4
            && iteration < maxIter)
        {
            z = Complex(re: pow(z.re, 2.0) - pow(z.im, 2.0) + c.re,
                        im: 2.0 * z.re * z.im + c.im);
            iteration += 1;
        }
        return iteration
    }
    func redrawFractal() {
        drawFractal(min, max, maxIteration)
    }
    func resetFractal() {
        min = Complex(re: -2.0, im: -1.0)
        max.re = 2.0
        max.im = min.im + (max.re - min.re) * height / width
        maxIteration = 25
        
        drawFractal(min, max, maxIteration)
    }
    private func drawFractal(_ min: Complex, _ max: Complex, _ maxIteration: Int) {
        fractalQueue.async {
            let rgbArray = self.setColors(min, max, maxIteration)
            let uiimage = self.getUIImage(rgbArray)
            self.delegate?.updateUIImage(uiimage: uiimage)
        }
    }
    private func getUIImage(_ rgbArray: [Rgb]) -> UIImage? {
        return imageFromArray.getUIImageFromColorArray(rgbArray)
    }
    private func setColors(_ min: Complex, _ max: Complex, _ maxIteration: Int) -> [Rgb] {
        var fractal = [Rgb](repeating: Color.black, count: len)
        let factor = Complex(re: (max.re - min.re) / (width - 1), im: (max.im - min.im) / (height - 1))
        fractal.withUnsafeMutableBufferPointer { fractalPtr in
            for y in 0..<Int(height) {
                DispatchQueue.concurrentPerform(iterations: Int(width)) { x in
                    let c = Complex(re: min.re + Double(x) * factor.re,
                                    im: max.im - Double(y) * factor.im)
                    let iteration = formula(c, maxIteration)
                    if iteration != maxIteration {
                        fractalPtr[y * Int(width) + x] = getColor(Double(iteration) / Double(maxIteration))
                    }
                }
            }
        }
        return fractal
    }
    private func interpolate(_ start: Double, _ end: Double, _ interpolation: Double) -> Double {
        return (start + ((end - start) * interpolation))
    }
    func scale(_ x: Int, _ y: Int, _ scale: Double) {
        let tap = Complex(re: Double(x) / (width / (max.re - min.re)) + min.re,
                          im: Double(y) / (height / (max.im - min.im)) * -1 + max.im)
        min.re = interpolate(tap.re, min.re, scale)
        min.im = interpolate(tap.im, min.im, scale)
        max.re = interpolate(tap.re, max.re, scale)
        max.im = interpolate(tap.im, max.im, scale)
        drawFractal(min, max, maxIteration)
    }
}
