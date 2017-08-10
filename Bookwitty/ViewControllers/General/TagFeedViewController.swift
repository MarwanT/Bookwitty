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
  let loaderNode: LoaderNode

  fileprivate let viewModel = TagFeedViewModel()


  fileprivate var loadingStatus: LoadingStatus = .none
  fileprivate var shouldShowLoader: Bool {
    return (loadingStatus != .none && loadingStatus != .reloading)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()

    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
}

// MARK: - Declarations
extension TagFeedViewController {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  enum Section: Int {
    case cards
    case activityIndicator

    static var numberOfSections: Int {
      return 2
    }
  }
}
