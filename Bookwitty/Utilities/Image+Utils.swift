//
//  Image.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

public extension UIImage {
  public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
    color.setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    guard let cgImage = image?.cgImage else { return nil }
    self.init(cgImage: cgImage)
  }
  
  func transform(withNewColor color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, scale)

    let context = UIGraphicsGetCurrentContext()!
    context.translateBy(x: 0, y: size.height)
    context.scaleBy(x: 1.0, y: -1.0)
    context.setBlendMode(.normal)

    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    context.clip(to: rect, mask: cgImage!)

    color.setFill()
    context.fill(rect)

    let newImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }
}


// MARK: - Image Scaling.
extension UIImage {
  func imageWithSize(size:CGSize) -> UIImage?
  {
    var scaledImageRect = CGRect.zero

    let aspectWidth:CGFloat = size.width / self.size.width
    let aspectHeight:CGFloat = size.height / self.size.height
    let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)

    scaledImageRect.size.width = self.size.width * aspectRatio
    scaledImageRect.size.height = self.size.height * aspectRatio
    scaledImageRect.origin.x = 0
    scaledImageRect.origin.y = 0

    UIGraphicsBeginImageContextWithOptions(scaledImageRect.size, false, 0)

    self.draw(in: scaledImageRect)

    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return scaledImage
  }

  func resizeImage(width: CGFloat, height: CGFloat) -> UIImage {
    let rect = AVMakeRect(aspectRatio: size, insideRect: CGRect(x: 0, y: 0, width: width, height: height))
    let newSize = CGSize(width: width, height: height)

    UIGraphicsBeginImageContext(newSize)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }
}
