//
//  ImageFromColorArray.swift
//  Fractal
//
//  Created by Ildar Usmanov on 02.06.2020.
//  Copyright © 2020 Ildar Usmanov. All rights reserved.
//

import Foundation
import UIKit

struct ImageFromColorArray {
    private let width: Int
    private let height: Int
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let bytesPerPoint = 4
    private let bytesPerRow: Int
    private let bytesPerData: Int
    private let bitsPerComponent = 8
    private let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue + CGImageAlphaInfo.premultipliedLast.rawValue

    init(frame: CGSize) {
        self.width = Int(frame.width)
        self.height = Int(frame.height)
        self.bytesPerRow = width * bytesPerPoint
        self.bytesPerData = bytesPerRow * height
    }
    
    func getUIImageFromColorArray(_ colors: [Rgb]) -> UIImage? {
        var data = colors // for mutable
        guard let providerRef = CGDataProvider(data: NSData(bytes: &data, length: bytesPerData))
            else { return nil }
        guard let cgImage = CGImage(width: width,
                                    height: height,
                                    bitsPerComponent: bitsPerComponent,
                                    bitsPerPixel: 32,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
                                    provider: providerRef,
                                    decode: nil,
                                    shouldInterpolate: true,
                                    intent: .defaultIntent)
            else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
