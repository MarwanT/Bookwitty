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
  var tags: [Tag]? { get set }
  var titleBodyHashValue: Int { get }
  var penName: PenName? { get set }

}

extension CandidatePost {
  var titleBodyHashValue: Int {
    return (title?.hashValue ?? 0)
      + (body?.hashValue ?? 0)
  }
}

extension Text: CandidatePost {
  var imageUrl: String? {
    get { return coverImageUrl }
    set { coverImageUrl = newValue }
  }
}
