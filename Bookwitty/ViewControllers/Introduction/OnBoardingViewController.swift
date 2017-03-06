//
//  OnBoardingViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingViewController: ASViewController<OnBoardingControllerNode> {
  let onBoardingNode: OnBoardingControllerNode
  let viewModel: OnBoardingViewModel = OnBoardingViewModel()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    onBoardingNode = OnBoardingControllerNode()
    super.init(node: onBoardingNode)

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    onBoardingNode.dataSource = self
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}

extension OnBoardingViewController: OnBoardingControllerDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfOnBoardingTitleSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItems()
  }

  func onBoardingCellNodeTitle(index: Int) -> String {
    return viewModel.onBoardingCellNodeTitle(index: index)
  }
}
