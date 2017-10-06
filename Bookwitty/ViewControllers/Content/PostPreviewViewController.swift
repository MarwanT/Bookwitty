//
//  PostPreviewViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/06.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class PostPreviewViewController: ASViewController<ASCollectionNode> {

  enum Sections: Int {
    case customize
    case penName
    case cover
    case title
    case description
    case newCover
    case newTitle

    static let count: Int = 7
  }
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
