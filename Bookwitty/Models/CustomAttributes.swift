//
//  CustomAttributes.swift
//  Bookwitty
//
//  Created by Marwan  on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class CuratedCollectionSectionsAttribute: Attribute {
  let sectionsString: String?
  
  init(sectionsString: String? = nil) {
    self.sectionsString = sectionsString
  }
}
