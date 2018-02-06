//
//  ImageResizingOperation.swift
//  
//
//  Created by Marwan  on 2/6/18.
//

import UIKit

class ImageResizingOperation: Operation {
  fileprivate(set) var image: UIImage?
  let resizingCriteria: ResizingCriteria
  
  init(image: UIImage, resizingCriteria: ResizingCriteria) {
    self.image = image
    self.resizingCriteria = resizingCriteria
  }
  
  override func main() {
    guard !isCancelled else {
      return
    }
    
    switch resizingCriteria {
    case .maximumDataCount(let dataCount):
      image = image?.resize(maximumDataCount: dataCount)
    }
  }
}

extension ImageResizingOperation {
  enum ResizingCriteria {
    case maximumDataCount(Int)
  }
}
