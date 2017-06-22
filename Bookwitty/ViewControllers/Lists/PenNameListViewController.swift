//
//  PenNameListViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PenNameListViewController: ASViewController<ASCollectionNode> {

  fileprivate let collectionNode: ASCollectionNode
  fileprivate var flowLayout: UICollectionViewFlowLayout
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  func initialize(with penNames: [PenName]) {
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.PenNameList)
  }

  fileprivate func initializeComponents() {
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true
  }
}
