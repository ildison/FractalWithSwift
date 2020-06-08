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
    private var formula: (Complex, Complex, Int) -> Int = {_,_,_ in return 0}
    private var imageFromArray: ImageFromColorArray
    private var min: Complex
    private var max = Complex()
    var maxIteration = 25
    private var height: Double
    private var width: Double
    private let len: Int
    weak var delegate: FractalDelegate?
//    private let dispatchQueue = DispatchQueue(label: , qos: .userInitiated, attributes: <#T##DispatchQueue.Attributes#>, autoreleaseFrequency: <#T##DispatchQueue.AutoreleaseFrequency#>, target: <#T##DispatchQueue?#>)

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

    private func mandelbrot(_ z: Complex, _ c: Complex, _ maxIter: Int) -> Int {
        var iteration = 0;
        var mutableZ = z
        while (pow(mutableZ.re, 2.0) + pow(mutableZ.im, 2.0) <= 4
            && iteration < maxIter)
        {
            mutableZ = Complex(re: pow(mutableZ.re, 2.0) - pow(mutableZ.im, 2.0) + c.re,
                        im: 2.0 * mutableZ.re * mutableZ.im + c.im);
            iteration += 1;
        }
        return iteration
    }
    func drawFractal() {
        let rgbArray = setColors()
        let uiimage = getUIImage(rgbArray)
        delegate?.updateUIImage(uiimage: uiimage)
        
    }
    private func getUIImage(_ rgbArray: [Rgb]) -> UIImage? {
        return imageFromArray.getUIImageFromColorArray(rgbArray)
    }
    private func setColors() -> [Rgb] {
        var fractal = [Rgb](repeating: Color.white, count: len)
        var y = 0.0;
        var c = Complex()
        let factor = Complex(re: (max.re - min.re) / (width - 1), im: (max.im - min.im) / (height - 1))
        while (y < height)
        {
            c.im = max.im - Double(y) * factor.im;
            var x = 0.0;
            while (x < width)
            {
                c.re = min.re + Double(x) * factor.re;
                let z = Complex(re: c.re, im: c.im);
                let iteration = formula(z, c, maxIteration)
                if iteration != maxIteration {
                    fractal[Int(y * width + x)] = getColor(Double(iteration) / Double(maxIteration))
                }
                x += 1;
            }
            y += 1;
        }
        return fractal
    }
    private func interpolate(_ start: Double, _ end: Double, _ interpolation: Double) -> Double {
        return (start + ((end - start) * interpolation))
    }
    func zoom(_ x: Int, _ y: Int) {
        let tap = Complex(re: Double(x) / (width / (max.re - min.re)) + min.re,
                          im: Double(y) / (height / (max.im - min.im)) * -1 + max.im)
        let zoom = 0.8
        min.re = interpolate(tap.re, min.re, zoom)
        min.im = interpolate(tap.im, min.im, zoom)
        max.re = interpolate(tap.re, max.re, zoom)
        max.im = interpolate(tap.im, max.im, zoom)
        drawFractal()
    }
}
