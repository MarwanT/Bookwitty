//
//  CommentsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol CommentsNodeDelegate: class {
  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action)
}

class CommentsNode: ASCellNode {
  let flowLayout: UICollectionViewFlowLayout
  let collectionNode: ASCollectionNode
  let loaderNode: LoaderNode
  
  var configuration = Configuration()
  
  let viewModel = CommentsViewModel()
  
  weak var delegate: CommentsNodeDelegate?
  
  var shouldShowLoader: Bool = false {
    didSet {
      updateCollectionNode(updateLoaderNode: true)
    }
  }
  
  var displayMode = DisplayMode.normal {
    didSet {
      viewModel.displayMode = displayMode
      setNeedsLayout()
    }
  }
  
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
  
  func reloadData() {
    shouldShowLoader = true
    viewModel.loadComments { (success, error) in
      self.shouldShowLoader = false
    }
  }
  
  fileprivate func loadNextPage(completion: @escaping (_ success: Bool) -> Void) {
    guard !viewModel.isFetchingData, viewModel.hasNextPage else {
      completion(false)
      return
    }
    
    shouldShowLoader = true
    viewModel.loadMore { (success, error) in
      self.shouldShowLoader = false
      completion(success)
    }
  }
  
  func updateCollectionNode(updateLoaderNode: Bool = false) {
    var reloadableSections: [Int] = [Section.read.rawValue]
    if updateLoaderNode {
      reloadableSections.append(Section.activityIndicator.rawValue)
    }
    
    let mutableIndexSet = NSMutableIndexSet()
    reloadableSections.forEach({ mutableIndexSet.add($0) })
    
    DispatchQueue.main.async {
      self.collectionNode.reloadSections(mutableIndexSet as IndexSet)
    }
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
          title: Strings.comments(),
          verticalBarColor: ThemeManager.shared.currentTheme.colorNumber6(),
          horizontalBarColor: ThemeManager.shared.currentTheme.colorNumber5())
        return headerNode
      case Section.write.rawValue:
        let writeCommentNode = WriteCommentNode()
        writeCommentNode.imageURL = URL(string: UserManager.shared.defaultPenName?.coverImageUrl ?? "")
        writeCommentNode.delegate = self
        return writeCommentNode
      case Section.read.rawValue:
        guard let comment = self.viewModel.comment(for: indexPath) else {
          return ASCellNode()
        }
        let commentTreeNode = CommentTreeNode()
        commentTreeNode.delegate = self
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
  
  func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard context.isFetching() else {
      return
    }
    
    context.beginBatchFetching()
    loadNextPage { (success) in
      context.completeBatchFetching(true)
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

// MARK: - Display Declaration
extension CommentsNode {
  enum DisplayMode {
    case normal
    case compact
  }
}

// MARK: - Actions Declaration
extension CommentsNode {
  enum Action {
    case viewRepliesForComment(comment: Comment)
    case writeComment(parentCommentIdentifier: String?)
  }
}

// MARK: - Comment tree delegate
extension CommentsNode: CommentTreeNodeDelegate {
  func commentTreeDidTapViewReplies(_ commentTreeNode: CommentTreeNode, comment: Comment) {
    delegate?.commentsNode(self, reactFor: .viewRepliesForComment(comment: comment))
  }
}

// MARK: - Write comment node delegate
extension CommentsNode: WriteCommentNodeDelegate {
  func writeCommentNodeDidTap(_ writeCommentNode: WriteCommentNode) {
    delegate?.commentsNode(self, reactFor: .writeComment(parentCommentIdentifier: nil))
  }
}
