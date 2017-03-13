//
//  PostsListViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import Spine

class PostsListViewController: ASViewController<ASCollectionNode> {
  fileprivate let collectionNodeLoadingSection: Int = 1
  fileprivate let collectionNodeItemsSection: Int = 0
  fileprivate let collectionNode: ASCollectionNode
  fileprivate let flowLayout: UICollectionViewFlowLayout
  fileprivate let loaderNode: LoaderNode


  var viewModel: PostsListViewModel

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init(title: String? = nil, ids: [String], preloadedList: [Resource]) {
    viewModel = PostsListViewModel(ids: ids, preloadedList: preloadedList)
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    super.init(node: collectionNode)

    collectionNode.style.flexGrow = 1
    collectionNode.style.flexShrink = 1
    collectionNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    self.title = title
  }

}
