//
//  Utilities.swift
//  Bookwitty
//
//  Created by Marwan  on 4/12/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

func mergeDictionaries<E,T>(left: [E: [T]], right: [E: [T]]) -> [E: [T]] {
  let uniqueKeys = Set(left.keys).union(Set(right.keys))

  var d3: [E : [T]] = [:]
  uniqueKeys.forEach { (key) in
    d3[key] = (left[key] ?? []) + (right[key] ?? [])
  }
  return d3
}
