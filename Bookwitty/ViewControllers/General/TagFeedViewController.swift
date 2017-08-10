//
//  TagFeedViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TagFeedViewController: ASViewController<ASCollectionNode> {

  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout

  fileprivate let viewModel = TagFeedViewModel()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
}
