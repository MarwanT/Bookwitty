//
//  CommentsNode.swift
//  Bookwitty
//
//  Created by Marwan  on 5/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol CommentsNodeDelegate: class {
  func commentsNode(_ commentsNode: CommentsNode, reactFor action: CommentsNode.Action, didFinishAction: ((_ success: Bool) -> ())?)
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
  
  func initialize(with manager: CommentsManager) {
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
    NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: CommentsManager.notificationName(for: postId), object: nil)
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

    //MARK: [Analytics] Event
    guard let postId = viewModel.postId,
      let resource = DataManager.shared.fetchResource(with: postId) as? ModelCommonProperties
      else { return }

    let category: Analytics.Category
    switch resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
    default:
      category = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: .LoadMoreComments,
                                                 name: name)
    Analytics.shared.send(event: event)
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
    guard let (action, comment) = notification.object as? CommentsManager.CommentNotificationObject else {
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
      case Section.parentComment.rawValue:
        guard let comment = self.viewModel.comment(for: indexPath) else {
          return ASCellNode()
        }
        let commentTreeNode = CommentTreeNode()
        commentTreeNode.delegate = self
        commentTreeNode.comment = comment
        commentTreeNode.configuration.shouldHideViewRepliesDisclosureNode = true
        return commentTreeNode
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
        writeCommentNode.imageURL = URL(string: UserManager.shared.defaultPenName?.avatarUrl ?? "")
        writeCommentNode.delegate = self
        return writeCommentNode
      case Section.read.rawValue:
        guard let comment = self.viewModel.comment(for: indexPath) else {
          return ASCellNode()
        }
        let commentTreeNode = CommentTreeNode()
        commentTreeNode.delegate = self
        commentTreeNode.comment = comment
        commentTreeNode.mode = self.displayMode == .compact ? .minimal : .normal
        var configuration = CommentTreeNode.Configuration()
        configuration.shouldHideViewRepliesDisclosureNode = self.displayMode == .compact
        configuration.leftIndentToParentNode = self.viewModel.isDisplayingACommentReplies
        commentTreeNode.configuration = configuration
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
      if let commentsManager = viewModel.commentsManagerClone() {
        delegate?.commentsNode(self, reactFor: .viewAllComments(commentsManager: commentsManager), didFinishAction: nil)

        //MARK: [Analytics] Event
        guard let postId = commentsManager.postIdentifier,
          let resource = DataManager.shared.fetchResource(with: postId) as? ModelCommonProperties
          else { return }

        let category: Analytics.Category
        switch resource.registeredResourceType {
        case Image.resourceType:
          category = .Image
        case Quote.resourceType:
          category = .Quote
        case Video.resourceType:
          category = .Video
        case Audio.resourceType:
          category = .Audio
        case Link.resourceType:
          category = .Link
        case Author.resourceType:
          category = .Author
        case ReadingList.resourceType:
          category = .ReadingList
        case Topic.resourceType:
          category = .Topic
        case Text.resourceType:
          category = .Text
        case Book.resourceType:
          category = .TopicBook
        case PenName.resourceType:
          category = .PenName
        default:
          category = .Default
        }

        let name: String = resource.title ?? ""
        let event: Analytics.Event = Analytics.Event(category: category,
                                                     action: .ViewAllComments,
                                                     name: name)
        Analytics.shared.send(event: event)
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
    case parentComment = 0
    case header
    case write
    case read
    case activityIndicator
    case viewAllComments
    
    static var numberOfSections: Int {
      return 6
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
    case viewRepliesForComment(comment: Comment, resource: ModelCommonProperties)
    case viewAllComments(commentsManager: CommentsManager)
    case writeComment(parentCommentIdentifier: String?, resource: ModelCommonProperties)
    case commentAction(comment: Comment, action: CardActionBarNode.Action)
  }
}

// MARK: - Comment tree delegate
extension CommentsNode: CommentTreeNodeDelegate {
  func commentTreeDidPerformAction(_ commentTreeNode: CommentTreeNode, comment: Comment, action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: nil)
      return
    }
    
    delegate?.commentsNode(self, reactFor: .commentAction(comment: comment, action: action), didFinishAction: didFinishAction)

    //MARK: [Analytics] Event
    guard let resource = viewModel.resource else { return }

    let analyticsAction: Analytics.Action

    let allowedActions: [CardActionBarNode.Action] = [.wit, .unwit, .reply]
    guard allowedActions.contains(action) else { return }

    let category: Analytics.Category
    switch resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
    default:
      category = .Default
    }

    switch action {
    case .wit:
      analyticsAction = .WitComment
    case .unwit:
      analyticsAction = .UnwitComment
    case .reply:
      analyticsAction = .ReplyToComment
    default:
      analyticsAction = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
  
  func commentTreeDidTapViewReplies(_ commentTreeNode: CommentTreeNode, comment: Comment) {
    guard let resource = viewModel.resource else {
      return
    }
    
    delegate?.commentsNode(self, reactFor: .viewRepliesForComment(comment: comment, resource: resource), didFinishAction: nil)

    //MARK: [Analytics] Event
    let category: Analytics.Category
    switch resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
    default:
      category = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: .ViewAllReplies,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}

// MARK: - Write comment node delegate
extension CommentsNode: WriteCommentNodeDelegate {
  func writeCommentNodeDidTap(_ writeCommentNode: WriteCommentNode) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      NotificationCenter.default.post( name: AppNotification.callToAction, object: nil)
      return
    }
    
    guard let resource = viewModel.resource else {
      return
    }

    delegate?.commentsNode(self, reactFor: .writeComment(parentCommentIdentifier: viewModel.parentCommentIdentifier, resource: resource), didFinishAction: nil)

    //MARK: [Analytics] Event
    let category: Analytics.Category
    switch resource.registeredResourceType {
    case Image.resourceType:
      category = .Image
    case Quote.resourceType:
      category = .Quote
    case Video.resourceType:
      category = .Video
    case Audio.resourceType:
      category = .Audio
    case Link.resourceType:
      category = .Link
    case Author.resourceType:
      category = .Author
    case ReadingList.resourceType:
      category = .ReadingList
    case Topic.resourceType:
      category = .Topic
    case Text.resourceType:
      category = .Text
    case Book.resourceType:
      category = .TopicBook
    case PenName.resourceType:
      category = .PenName
    default:
      category = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: .AddComment,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}

// MARK: - Display Helpers
extension CommentsNode {
  static func concatenate(with node: ASDisplayNode, resource: ModelCommonProperties?) -> (wrapperNode: ASDisplayNode, commentsNode: CommentsNode) {
    let commentsNode = CommentsNode()
    commentsNode.displayMode = .compact
    let commentsManager = CommentsManager()
    commentsManager.initialize(resource: resource)
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
  func publishComment(content: String?, parentCommentId: String?, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    viewModel.publishComment(content: content, parentCommentId: parentCommentId) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func wit(comment: Comment, completion: ((_ success: Bool, _ error: CommentsManager.Error?) -> Void)?) {
    viewModel.wit(comment: comment) {
      (success, error) in
      completion?(success, error)
    }
  }
  
  func unwit(comment: Comment, completion: ((_ success: Bool, _ error: CommentsManager.Error?) -> Void)?) {
    viewModel.unwit(comment: comment) {
      (success, error) in
      completion?(success, error)
    }
  }
}
