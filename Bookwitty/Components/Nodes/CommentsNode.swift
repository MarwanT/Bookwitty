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
  
  let viewModel = CommentsViewModel()
  
  override init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()
    
    super.init()
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    
    automaticallyManagesSubnodes = true
  }
  
  func initialize(with manager: CommentManager) {
    viewModel.initialize(with: manager)
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    collectionNode.style.preferredSize = constrainedSize.max
    let externalInsetsSpec = ASInsetLayoutSpec(insets: configuration.externalInsets, child: collectionNode)
    return externalInsetsSpec
  }
}

// MARK: - Collection View Delegates
extension CommentsNode: ASCollectionDelegate, ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSection
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case Section.activityIndicator.rawValue:
      return shouldShowLoader ? 1 : 0
    default:
      return viewModel.numberOfItems(in: section)
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      switch indexPath.section {
      case Section.header.rawValue:
        let externalInsets = UIEdgeInsets(
          top: ThemeManager.shared.currentTheme.generalExternalMargin(),
          left: 0, bottom: 0, right: 0)
        let headerNode = SectionTitleHeaderNode(externalInsets: externalInsets)
        headerNode.setTitle(
          title: "Comments", // TODO: Localize
          verticalBarColor: ThemeManager.shared.currentTheme.colorNumber6(),
          horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber5())
        return headerNode
      case Section.write.rawValue:
        return ASCellNode()
      case Section.read.rawValue:
        guard let comment = self.viewModel.comment(for: indexPath) else {
          return ASCellNode()
        }
        let commentTreeNode = CommentTreeNode()
        commentTreeNode.comment = comment
        return commentTreeNode
      case Section.activityIndicator.rawValue:
        return self.loaderNode
      default:
        return ASCellNode()
      }
    }
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    switch node {
    case loaderNode:
      loaderNode.updateLoaderVisibility(show: true)
    default:
      return
    }
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
