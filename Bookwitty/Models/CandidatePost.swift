//
//  CandidatePost.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/12.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

protocol CandidatePost {
  var title: String? { get set }
  var body: String? { get set }
  var shortDescription: String? { get set }
  var imageUrl: String? { get set }
}
