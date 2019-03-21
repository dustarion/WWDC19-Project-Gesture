//
//  ImageDifference.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 21/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

import UIKit
import CoreMedia

//func differenceOf(_ top: UIImage?, with bottom: UIImage?) -> UIImage? {
//    guard let topRef = top!.cgImage else { return nil }
//    guard let bottomRef = bottom!.cgImage else { return nil }
//    
//    // Dimensions
//    let bottomFrame = CGRect(x: 0, y: 0, width: bottomRef.width, height: bottomRef.height)
//    let topFrame = CGRect(x: 0, y: 0, width: topRef.width, height: topRef.height)
//    let renderFrame: CGRect = bottomFrame.union(topFrame).integral
//    
//    // Create context
//    let colorSpace = CGColorSpaceCreateDeviceRGB()
//    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
//    
//    guard let context = CGContext(data: nil, width: Int(renderFrame.size.width), height: Int(renderFrame.size.height), bitsPerComponent: 8, bytesPerRow: Int(renderFrame.size.width * 4), space: colorSpace, bitmapInfo: bitmapInfo)
//        else { return nil }
//    
//    // Draw images
//    context.setBlendMode(CGBlendMode.normal)
//    context.draw(bottomRef, in: bottomFrame.offsetBy(dx: -renderFrame.origin.x, dy: -renderFrame.origin.y))
//    context.setBlendMode(CGBlendMode.difference)
//    context.draw(topRef, in: topFrame.offsetBy(dx: -renderFrame.origin.x, dy: -renderFrame.origin.y))
//    
//    // Create image from context
//    guard let imageRef = context.makeImage() else { return nil }
//    let image = UIImage(cgImage: imageRef)
//    return image
//}
