//
//  PageViewModel.swift
//  Bookwitty
//
//  Created by Marwan  on 1/24/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

typealias InstructionData = (title: String?, description: String?, iamge: UIImage)

struct TutorialViewModel {
  var instructionsData: [InstructionData] = [InstructionData]()
}
