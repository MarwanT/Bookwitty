//
//  Banner.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout

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
    setConstraints()
  }
  
  private func addSubviews() {
    labelsContainerView.addSubview(titleLabel)
    labelsContainerView.addSubview(descriptionLabel)
    self.addSubview(imageView)
    self.addSubview(labelsContainerView)
    
    self.insertSubview(dimView, aboveSubview: imageView)
  }
  
  func setConstraints() {
    let descriptionTopSpace: CGFloat = ThemeManager.shared.currentTheme.titleMargin()
    let minimumHeight: CGFloat = 150
    
    imageView.alignTop("0@500", leading: "0", bottom: "0@500", trailing: "0", toView: self)
    self.constrainHeight("\(minimumHeight)@750")
    
    titleLabel.alignLeading("0", trailing: "0", toView: labelsContainerView)
    descriptionLabel.alignLeading("0", trailing: "0", toView: labelsContainerView)
    titleLabel.alignTopEdge(withView: labelsContainerView, predicate: "0")
    descriptionLabel.constrainTopSpace(toView: titleLabel, predicate: "\(descriptionTopSpace)")
    labelsContainerView.alignBottomEdge(withView: descriptionLabel, predicate: "0")
    
    labelsContainerView.alignLeading("0", trailing: "0", toView: self)
    labelsContainerView.alignCenterY(withView: self, predicate: "0")
    labelsContainerView.alignTopEdge(withView: self, predicate: ">=10")
    
    dimView.alignTop("0", leading: "0", bottom: "0", trailing: "0", toView: imageView)
  }
}
