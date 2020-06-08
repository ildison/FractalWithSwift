//
//  Color.swift
//  Fractal
//
//  Created by Ildar Usmanov on 02.06.2020.
//  Copyright © 2020 Ildar Usmanov. All rights reserved.
//

import Foundation

struct Rgb {
    var r:UInt8
    var g:UInt8
    var b:UInt8
    let a:UInt8 = 255
}

struct Color {
    static let white = Rgb(r: 255, g: 255, b: 255)
    static let black = Rgb(r: 0, g: 0, b: 0)
}
