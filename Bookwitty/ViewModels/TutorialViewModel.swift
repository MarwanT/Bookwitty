//
//  PageViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

typealias TutorialPageData = (title: String?, description: String?, image: UIImage, color: UIColor?)

struct TutorialViewModel {
  var tutorialPageData: [TutorialPageData] = [TutorialPageData]()
}
