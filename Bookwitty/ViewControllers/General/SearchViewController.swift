//
//  SearchViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class SearchViewController: ASViewController<ASCollectionNode> {
  var flowLayout: UICollectionViewFlowLayout
  var collectionNode: ASCollectionNode

  var searchBar: UISearchBar?

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureSearchController()
  }

  func configureSearchController() {
    let navHeight: CGFloat = navigationController?.navigationBar.frame.size.height ?? 0.0
    let sideMargin: CGFloat = 34.0
    let size: CGSize = CGSize(width: UIScreen.main.bounds.width - sideMargin, height: navHeight)

    searchBar = UISearchBar(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
    searchBar?.barStyle = .black
    searchBar?.searchBarStyle = .prominent
    searchBar?.showsCancelButton = false
    searchBar?.sizeToFit()

    if let searchBar = searchBar {
      let leftNavBarButton = UIBarButtonItem(customView: searchBar)
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
  }
}
