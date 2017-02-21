//
//  ValueFormatters.swift
//  Bookwitty
//
//  Created by Marwan  on 2/20/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

class CuratedCollectionSectionsValueFormatter: ValueFormatter {
  typealias FormattedType = [String : Any]
  typealias UnformattedType = CuratedCollectionSections
  typealias AttributeType = CuratedCollectionSectionsAttribute
  
  func unformatValue(_ value: [String : Any], forAttribute: CuratedCollectionSectionsAttribute) -> CuratedCollectionSections {
    return CuratedCollectionSections(for: value)
  }
  
  func formatValue(_ value: CuratedCollectionSections, forAttribute: CuratedCollectionSectionsAttribute) -> [String : Any] {
    // TODO: Implement this
    return ["" : ""]
  }
}
