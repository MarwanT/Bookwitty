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
  let viewCommentsDisclosureNode: DisclosureNodeCell
  
  var configuration = Configuration()
  
  let viewModel = CommentsViewModel()
  
  fileprivate var contentSize: CGSize = CGSize.zero
  
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
    viewCommentsDisclosureNode = DisclosureNodeCell()
    
    super.init()
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    
    var disclosureNodeConfiguration = DisclosureNodeCell.Configuration()
    disclosureNodeConfiguration.style = .highlighted
    disclosureNodeConfiguration.addInternalTopSeparator = true
    disclosureNodeConfiguration.addInternalBottomSeparator = true
    viewCommentsDisclosureNode.configuration = disclosureNodeConfiguration
    viewCommentsDisclosureNode.text = Strings.view_all_comments()
    
    automaticallyManagesSubnodes = true
  }
  
  deinit {
    collectionNode.view.removeObserver(self, forKeyPath: #keyPath(UICollectionView.contentSize))
    unregisterNotification()
  }
  
  override func didLoad() {
    super.didLoad()
    collectionNode.view.addObserver(
      self,
      forKeyPath: #keyPath(UICollectionView.contentSize),
      options: [NSKeyValueObservingOptions.new, NSKeyValueObservingOptions.old],
      context: nil)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let keyPath = keyPath, keyPath == #keyPath(UICollectionView.contentSize) else {
      return
    }
    
    guard let oldSize = change?[NSKeyValueChangeKey.oldKey] as? CGSize,
      let newSize = change?[NSKeyValueChangeKey.newKey] as? CGSize else {
        return
    }
    contentSize = newSize
    
    if oldSize != newSize {
      updateNodeHeight()
      setNeedsLayout()
    }
  }
  
  func initialize(with manager: CommentManager) {
    viewModel.initialize(with: manager)
    registerNotification()
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    updateNodeHeight()
    
    var collectionSize = constrainedSize.max
    if constrainedSize.max.height == CGFloat.infinity {
      collectionSize = constrainedSize.min
    }
    collectionNode.style.preferredSize = collectionSize
    let externalInsetsSpec = ASInsetLayoutSpec(insets: configuration.externalInsets, child: collectionNode)
    return externalInsetsSpec
  }
  
  private func registerNotification() {
    unregisterNotification()
    guard let postId = viewModel.postId else {
      return
    }
    NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: CommentManager.notificationName(for: postId), object: nil)
  }
  
  private func unregisterNotification() {
    NotificationCenter.default.removeObserver(self)
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
    var reloadableSections: [Int] = [Section.read.rawValue, Section.viewAllComments.rawValue]
    if updateLoaderNode {
      reloadableSections.append(Section.activityIndicator.rawValue)
    }
    
    let mutableIndexSet = NSMutableIndexSet()
    reloadableSections.forEach({ mutableIndexSet.add($0) })
    
    DispatchQueue.main.async {
      self.collectionNode.reloadSections(mutableIndexSet as IndexSet)
    }
  }
  
  func updateNodeHeight() {
    if case DisplayMode.compact = displayMode {
      style.height = ASDimensionMake(contentSize.height)
    }
  }
}

// MARK: - Notification
extension CommentsNode {
  func handleNotification(_ notification: Notification) {
    guard let (action, comment) = notification.object as? CommentManager.CommentNotificationObject else {
      return
    }
    
    switch action {
    case .commentAction:
      viewModel.updateData(with: comment)
      updateCollectionNode()
    case .writeComment:
      reloadData()
    default:
      break
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
        commentTreeNode.configuration.shouldHideViewRepliesDisclosureNode = (self.displayMode == .compact) ? true : false 
        return commentTreeNode
      case Section.activityIndicator.rawValue:
        return self.loaderNode
      case Section.viewAllComments.rawValue:
        return self.viewCommentsDisclosureNode
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
  
  func collectionNode(_ collectionNode: ASCollectionNode, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    guard let section = Section(rawValue: indexPath.section), section == .viewAllComments else {
      return false
    }
    return true
  }
  
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    collectionNode.deselectItem(at: indexPath, animated: true)
    
    if viewCommentsDisclosureNode === collectionNode.nodeForItem(at: indexPath) {
      if let commentManager = viewModel.commentManagerClone() {
        delegate?.commentsNode(self, reactFor: .viewAllComments(commentManager: commentManager))
      }
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
    case viewAllComments
    
    static var numberOfSections: Int {
      return 5
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
    case viewRepliesForComment(comment: Comment, postId: String)
    case viewAllComments(commentManager: CommentManager)
    case writeComment(parentCommentIdentifier: String?, postId: String)
    case commentAction(comment: Comment, action: CardActionBarNode.Action)
  }
}

// MARK: - Comment tree delegate
extension CommentsNode: CommentTreeNodeDelegate {
  func commentTreeDidPerformAction(_ commentTreeNode: CommentTreeNode, comment: Comment, action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?) {
    delegate?.commentsNode(self, reactFor: .commentAction(comment: comment, action: action))
  }
  
  func commentTreeDidTapViewReplies(_ commentTreeNode: CommentTreeNode, comment: Comment) {
    guard let postId = viewModel.postId else {
      return
    }
    delegate?.commentsNode(self, reactFor: .viewRepliesForComment(comment: comment, postId: postId))
  }
}

// MARK: - Write comment node delegate
extension CommentsNode: WriteCommentNodeDelegate {
  func writeCommentNodeDidTap(_ writeCommentNode: WriteCommentNode) {
    guard let postId = viewModel.postId else {
      return
    }
    delegate?.commentsNode(self, reactFor: .writeComment(parentCommentIdentifier: viewModel.parentCommentIdentifier, postId: postId))
  }
}

// MARK: - Display Helpers
extension CommentsNode {
  static func concatinate(with node: ASDisplayNode, resourceIdentifier: String) -> (wrapperNode: ASDisplayNode, commentsNode: CommentsNode) {
    let commentsNode = CommentsNode()
    commentsNode.displayMode = .compact
    let commentsManager = CommentManager()
    commentsManager.initialize(postIdentifier: resourceIdentifier)
    commentsNode.initialize(with: commentsManager)
    commentsNode.reloadData()
    
    let containerNode = ASDisplayNode()
    containerNode.automaticallyManagesSubnodes = true
    containerNode.layoutSpecBlock = { (_, _) -> ASLayoutSpec in
      return ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .stretch, children: [node, commentsNode])
    }
    return (containerNode, commentsNode)
  }
}

// MARK: - Comment intences related methods
extension CommentsNode {
  func publishComment(content: String?, parentCommentId: String?, completion: @escaping (_ success: Bool, _ error: CommentManager.Error?) -> Void) {
    viewModel.publishComment(content: content, parentCommentId: parentCommentId) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func wit(comment: Comment, completion: ((_ success: Bool, _ error: CommentManager.Error?) -> Void)?) {
    viewModel.wit(comment: comment) {
      (success, error) in
      completion?(success, error)
    }
  }
  
  func unwit(comment: Comment, completion: ((_ success: Bool, _ error: CommentManager.Error?) -> Void)?) {
    viewModel.unwit(comment: comment) {
      (success, error) in
      completion?(success, error)
    }
  }
  
  func dim(comment: Comment, completion: ((_ success: Bool, _ error: CommentManager.Error?) -> Void)?) {
    viewModel.dim(comment: comment) {
      (success, error) in
      completion?(success, error)
    }
  }
  
  func undim(comment: Comment, completion: ((_ success: Bool, _ error: CommentManager.Error?) -> Void)?) {
    viewModel.undim(comment: comment) {
      (success, error) in
      completion?(success, error)
    }
  }
}
