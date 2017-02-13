//
//  Banner.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class Banner: UIView {
  let imageView = UIImageView(frame: CGRect.zero)
  let labelsContainerView = UIView(frame: CGRect.zero)
  let titleLabel = UILabel(frame: CGRect.zero)
  let descriptionLabel = UILabel(frame: CGRect.zero)
  let dimView: UIView = UIView(frame: CGRect.zero)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  private func initialize() {
    addSubviews()
  }
  
  private func addSubviews() {
    labelsContainerView.addSubview(titleLabel)
    labelsContainerView.addSubview(descriptionLabel)
    self.addSubview(imageView)
    self.addSubview(labelsContainerView)
    
    self.insertSubview(dimView, aboveSubview: imageView)
  }
}
