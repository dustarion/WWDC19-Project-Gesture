//
//  Extensions.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 25/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

import UIKit
import CoreML

extension Double {
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImage {
    
    func resize(to newSize: CGSize) -> UIImage? {
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func pixelBuffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_OneComponent8, nil, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let colorspace = CGColorSpaceCreateDeviceGray()
        let bitmapContext = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorspace, bitmapInfo: 0)!
        
        guard let cg = self.cgImage else {
            return nil
        }
        
        bitmapContext.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelBuffer
    }
    
}

extension UITouch {
    
    func isInView(_ view: UIView) -> Bool {
        let loc = location(in: view)
        guard loc.x >= 0 && loc.x <= view.frame.size.width else { return false }
        return loc.y >= 0 && loc.y <= view.frame.size.height
    }
    
}

extension UIColor {
    
    convenience init?(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
        guard red >= 0 && red <= 255 else { return nil }
        guard green >= 0 && green <= 255 else { return nil }
        guard blue >= 0 && blue <= 255 else { return nil }
        
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
    }
    
    convenience init?(hex: Int, transparency: CGFloat = 1) {
        var trans = transparency
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        self.init(red: red, green: green, blue: blue, transparency: trans)
    }
    
}

