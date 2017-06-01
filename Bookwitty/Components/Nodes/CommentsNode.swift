//
//  CommentsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class CommentsNode: ASCellNode {
  let flowLayout: UICollectionViewFlowLayout
  let collectionNode: ASCollectionNode
  let loaderNode: LoaderNode
  
  override init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()
    
    super.init()
    
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    
    automaticallyManagesSubnodes = true
  }
}

// MARK: - Section Declaration
extension CommentsNode {
  enum Section: Int {
    case header = 0
    case write
    case read
    case activityIndicator
    
    static var numberOfSections: Int {
      return 4
    }
  }
}
