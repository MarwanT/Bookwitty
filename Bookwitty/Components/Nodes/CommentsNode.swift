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
  
  var configuration = Configuration()
  
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

// MARK: - Configuration Declaration
extension CommentsNode {
  struct Configuration {
    var externalInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
