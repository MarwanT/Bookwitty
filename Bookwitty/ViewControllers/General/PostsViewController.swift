//
//  PostsViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class PostsViewController: ASViewController<ASCollectionNode> {
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let loaderNode: LoaderNode
  
  let viewModel = PostsViewModel()
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  init() {
    let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(
      top: externalMargin, left: 0,
      bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    
    loaderNode = LoaderNode()
    
    super.init(node: collectionNode)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    if viewModel.hasNoPosts {
      loadNextPage(completion: { (success) in
        print("Fist Page Loaded")
      })
    }
  }
  
  fileprivate func loadNextPage(completion: @escaping (_ success: Bool) -> Void) {
    guard !viewModel.isLoadingNextPage else {
      return
    }
    
    showBottomLoader(reloadSection: true)
    viewModel.loadNextPage { (success) in
      self.hideBottomLoader()
      let sectionsNeedsReloading = self.viewModel.sectionsNeedsReloading()
      self.reloadCollectionViewSections(sections: sectionsNeedsReloading)
      completion(success)
    }
  }
}

// MARK: - Helpers
extension PostsViewController {
  fileprivate func showBottomLoader(reloadSection: Bool = false) {
  }
  
  fileprivate func hideBottomLoader(reloadSection: Bool = false) {
  }
  
  func reloadCollectionViewSections(sections: [Section]) {
    let mutableIndexSet = NSMutableIndexSet()
    sections.forEach({ mutableIndexSet.add($0.rawValue) })
    collectionNode.reloadSections(mutableIndexSet as IndexSet)
  }
}

// MARK: - Load More
extension PostsViewController {
  func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    return viewModel.hasNextPage
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard context.isFetching() else {
      return
    }
    
    context.beginBatchFetching()
    
    self.loadNextPage { (success) in
      defer {
        context.completeBatchFetching(true)
      }
    }
  }
}

// MARK: - Collection view data source and delegate
extension PostsViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItemsForSection(for: section)
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    if Section.activityIndicator.rawValue == indexPath.section {
      return {
        return self.loaderNode
      }
    } else {
      return {
        let baseCardNode = self.viewModel.nodeForItem(at: indexPath) ?? BaseCardPostNode()
        baseCardNode.delegate = self
        return baseCardNode
      }
    }
  }
}

// MARK: - Base card post node delegate
extension PostsViewController: BaseCardPostNodeDelegate {
  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?) {
    // TODO: Implement Card action
  }
}

// MARK: - Declarations
extension PostsViewController {
  enum Section: Int {
    case posts = 0
    case activityIndicator
    
    static var numberOfSections: Int {
      return 2
    }
  }
}
