//
//  PostPreviewViewModel.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/12.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class PostPreviewViewModel {
  var candidatePost: CandidatePost!

  func initialize(with post: CandidatePost) {
    self.candidatePost = post
  }
}
