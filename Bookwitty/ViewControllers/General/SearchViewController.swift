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
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }
  var flowLayout: UICollectionViewFlowLayout
  var collectionNode: ASCollectionNode

  var searchBar: UISearchBar?
  var viewModel: SearchViewModel = SearchViewModel()
  var loadingStatus: LoadingStatus = .none

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
    searchBar?.placeholder = Strings.search_placeholder()
    searchBar?.delegate = self
    searchBar?.showsCancelButton = false
    searchBar?.sizeToFit()

    if let searchBar = searchBar {
      let leftNavBarButton = UIBarButtonItem(customView: searchBar)
      self.navigationItem.leftBarButtonItem = leftNavBarButton
    }
  }

  fileprivate func searchAction(query: String?) {
    guard let query = query else {
      return
    }
    loadingStatus = .loading
    viewModel.search(query: query) { (success, error) in
      //TODO: handle search result
      self.loadingStatus = .none
    }
  }
}

extension SearchViewController: UISearchBarDelegate {
  public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    return true
  }

  public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true
  }

  public func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = false
    searchBar.endEditing(true)
    return true
  }

  public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.endEditing(true)
    searchAction(query: searchBar.text)
  }

  public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.showsCancelButton = false
    searchBar.endEditing(true)
  }
}
