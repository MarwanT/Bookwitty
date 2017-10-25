//
//  CandidatePost.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/12.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol CandidatePost {
  var id: String? { get }
  var title: String? { get set }
  var body: String? { get set }
  var shortDescription: String? { get set }
  var imageUrl: String? { get set }
  var penName: PenName? { get set }
  var status: String? { get set }
}

extension CandidatePost {
  
  fileprivate func combineHashes(_ hashes: [Int]) -> Int {
    return hashes.reduce(0, combineHashValues)
  }
  
  fileprivate func combineHashValues(_ initial: Int, _ other: Int) -> Int {
    #if arch(x86_64) || arch(arm64)
      let magic: UInt = 0x9e3779b97f4a7c15
    #elseif arch(i386) || arch(arm)
      let magic: UInt = 0x9e3779b9
    #endif
    var lhs = UInt(bitPattern: initial)
    let rhs = UInt(bitPattern: other)
    lhs ^= rhs &+ magic &+ (lhs << 6) &+ (lhs >> 2)
    return Int(bitPattern: lhs)
  }
  
  var hash: Int {
    let titleHash = title?.hashValue ?? 0
    let bodyHash = body?.hashValue ?? 0
    let shortDescriptionHash = shortDescription?.hashValue ?? 0
    let imageUrlHash =  imageUrl?.hashValue ?? 0
    return combineHashes([titleHash, bodyHash, shortDescriptionHash, imageUrlHash])
  }
}

extension Text: CandidatePost {
  var imageUrl: String? {
    get { return coverImageUrl }
    set { coverImageUrl = newValue }
  }
}
