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
  var title: String? { get }
  var createdAt: String? { get }
  var updatedAt: String? { get }
  var thumbnailImageUrl: String? { get }
  var coverImageUrl: String? { get }
  var shortDescription: String? { get }
}
