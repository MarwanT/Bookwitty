//
//  SelectedImageView.swift
//  Bookwitty
//
//  Created by ibrahim on 11/10/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

final class SelectedImageView: UIImageView {
  private var selected = false
  
  var isSelected : Bool {
    get {
      return selected
    }
    set {
      selected = newValue
    }
  }
}

