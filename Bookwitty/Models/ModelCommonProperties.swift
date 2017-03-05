//
//  ModelCommonProperties.swift
//  Bookwitty
//
//  Created by Marwan  on 2/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

protocol ModelCommonProperties {
  var id: String? { get }
  var title: String? { get }
  var createdAt: NSDate? { get }
  var updatedAt: NSDate? { get }
  var thumbnailImageUrl: String? { get }
  var coverImageUrl: String? { get }
  var shortDescription: String? { get }
}

extension Video: ModelCommonProperties {
}

extension Topic: ModelCommonProperties {
  var title: String? { return nil }
}

extension Image: ModelCommonProperties {
}

extension Author: ModelCommonProperties {
}

extension Link: ModelCommonProperties {
}

extension ReadingList: ModelCommonProperties {
}

extension Audio: ModelCommonProperties {
}

extension Text: ModelCommonProperties {
}

extension Quote: ModelCommonProperties {
  var shortDescription: String? { return nil }
}

extension Book: ModelCommonProperties {
  var shortDescription: String? {
    return nil
  }

}
