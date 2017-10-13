//
//  DraftsViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/13.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class DraftsViewController: ASViewController<ASCollectionNode> {

  fileprivate var flowLayout: UICollectionViewFlowLayout
  fileprivate let collectionNode: ASCollectionNode

  init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()
  }

  fileprivate func initializeComponents() {
    
  }
}
