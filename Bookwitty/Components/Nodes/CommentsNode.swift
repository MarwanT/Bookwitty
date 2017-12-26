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
  let composerPlaceholder: WriteCommentNode
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
    composerPlaceholder = WriteCommentNode()
    viewCommentsDisclosureNode = DisclosureNodeCell()
    
    super.init()
    
    collectionNode.delegate = self
    collectionNode.dataSource = self
    
    loaderNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    
    composerPlaceholder.delegate = self
    composerPlaceholder.configuration.displayTopSeparator = true
    composerPlaceholder.backgroundColor = UIColor.white
    
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
  
  func initialize(with resource: ModelCommonProperties, parentCommentIdentifier: String? = nil) {
    viewModel.initialize(with: resource, parentCommentIdentifier: parentCommentIdentifier)
    registerNotification()
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    updateNodeHeight()
    
    var collectionSize = constrainedSize.max
    if constrainedSize.max.height == CGFloat.infinity {
      collectionSize = constrainedSize.min
    }
    collectionNode.style.preferredSize = collectionSize
    
    var stackElements: [ASLayoutElement] = []
    stackElements.append(collectionNode)
    if displayMode == .normal {
      stackElements.append(composerPlaceholder)
      
      // Deduce the composer height from the collectionSize
      collectionNode.style.preferredSize.height -= composerPlaceholder.minCalculatedHeight
    }
    let contentStack = ASStackLayoutSpec(
      direction: .vertical, spacing: 0, justifyContent: .start,
      alignItems: .stretch, children: stackElements)
    let externalInsetsSpec = ASInsetLayoutSpec(
      insets: configuration.externalInsets, child: contentStack)
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
    viewModel.load { (success, error) in
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
    var reloadableSections: [Int] = [Section.parentComment.rawValue, Section.read.rawValue, Section.viewAllComments.rawValue]
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
    guard let (notificationAction, commentIdentifier) = notification.object as? CommentsManager.CommentNotificationObject else {
      return
    }
    
    switch notificationAction {
    case .commentAction:
      guard case .commentAction(let commentIdentifier, let action, _, _) = notificationAction else {
        return
      }
      switch action {
      case .wit, .unwit:
        updateCollectionNode()
      default:
        break
      }
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
      case Section.count.rawValue:
        let countCell = CommentsCountCellNode()
        countCell.text = self.viewModel.displayedTotalNumberOfComments
        return countCell
      case Section.parentComment.rawValue:
        guard let commentInfo = self.viewModel.commentInfo(for: indexPath) else {
          return ASCellNode()
        }
        let commentTreeNode = CommentTreeNode()
        commentTreeNode.initialize(with: CommentTreeNode.DisplayMode.parentOnly)
        commentTreeNode.delegate = self
        commentTreeNode.commentIdentifier = commentInfo.id
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
        writeCommentNode.initialize(with: .bordered)
        writeCommentNode.configuration.externalInsets.top = 25
        writeCommentNode.configuration.externalInsets.bottom = 15
        writeCommentNode.imageURL = URL(string: UserManager.shared.defaultPenName?.avatarUrl ?? "")
        writeCommentNode.delegate = self
        return writeCommentNode
      case Section.read.rawValue:
        guard let commentInfo = self.viewModel.commentInfo(for: indexPath) else {
          return ASCellNode()
        }
        let commentTreeNode = CommentTreeNode()
        commentTreeNode.initialize(with: self.displayMode == .compact ? .minimal : .normal)
        commentTreeNode.delegate = self
        commentTreeNode.commentIdentifier = commentInfo.id
        commentTreeNode.isReplyTree = self.viewModel.isDisplayingACommentReplies
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
      if let resource = viewModel.resource {
        let parentCommentIdentifier = viewModel.parentCommentIdentifier
        delegate?.commentsNode(self, reactFor: .viewAllComments(resource: resource, parentCommentIdentifier: parentCommentIdentifier), didFinishAction: nil)

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
    case count = 0
    case parentComment
    case header
    case write
    case read
    case activityIndicator
    case viewAllComments
    
    static var numberOfSections: Int {
      return 7
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
    case viewReplies(resource: ModelCommonProperties, parentCommentIdentifier: String)
    case viewAllComments(resource: ModelCommonProperties, parentCommentIdentifier: String?)
    case writeComment(resource: ModelCommonProperties, parentCommentIdentifier: String?)
    case commentAction(commentIdentifier: String, action: CardActionBarNode.Action, resource: ModelCommonProperties, parentCommentIdentifier: String?)
  }
}

// MARK: - Comment tree delegate
extension CommentsNode: CommentTreeNodeDelegate {
  func commentTreeDidPerformAction(_ commentTreeNode: CommentTreeNode, commentIdentifier: String, action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((Bool) -> ())?) {
    guard UserManager.shared.isSignedIn else {
      //If user is not signed In post notification and do not fall through
      didFinishAction?(false)
      NotificationCenter.default.post( name: AppNotification.callToAction, object: nil)
      return
    }
    
    guard let resource = viewModel.resource else {
      didFinishAction?(false)
      return
    }
    
    let parentCommentIdentifier = viewModel.parentIdentifier(forCommentWithIdentifier: commentIdentifier, action: action)
    delegate?.commentsNode(self, reactFor: .commentAction(commentIdentifier: commentIdentifier, action: action, resource: resource, parentCommentIdentifier: parentCommentIdentifier), didFinishAction: didFinishAction)

    //MARK: [Analytics] Event
    let analyticsAction: Analytics.Action

    let allowedActions: [CardActionBarNode.Action] = [.wit, .unwit, .reply, .remove]
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
    case .remove:
      analyticsAction = .RemoveComment
    default:
      analyticsAction = .Default
    }

    let name: String = resource.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
  
  func commentTreeDidTapViewReplies(_ commentTreeNode: CommentTreeNode, commentIdentifier: String) {
    guard let resource = viewModel.resource else {
      return
    }
    
    delegate?.commentsNode(self, reactFor: .viewReplies(resource: resource, parentCommentIdentifier: commentIdentifier), didFinishAction: nil)

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

  func commentTreeParentIdentifier(_ node: CommentTreeNode, commentIdentifier: String) -> String? {
    return viewModel.parentIdentifier(for: commentIdentifier)
  }
  
  func commentTreeInfo(_ node: CommentTreeNode, commentIdentifier: String) -> CommentInfo? {
    return viewModel.commentInfo(forCommentWithIdentifier: commentIdentifier)
  }
  
  func commentTreeRepliesCount(_ node: CommentTreeNode, commentIdentifier: String) -> Int {
    return viewModel.commentInfo(forCommentWithIdentifier: commentIdentifier)?.numberOfReplies ?? 0
  }
  
  func commentTreeRepliesInfo(_ node: CommentTreeNode, commentIdentifier: String) -> [CommentInfo] {
    return viewModel.repliesInfo(forParentCommentIdentifier: commentIdentifier)
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

    let parentCommentIdentifier = viewModel.parentCommentIdentifier
    delegate?.commentsNode(self, reactFor: .writeComment(resource: resource, parentCommentIdentifier: parentCommentIdentifier), didFinishAction: nil)
    
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
  static func concatenate(with node: ASDisplayNode, resource: ModelCommonProperties) -> (wrapperNode: ASDisplayNode, commentsNode: CommentsNode) {
    let commentsNode = CommentsNode()
    commentsNode.displayMode = .compact
    commentsNode.initialize(with: resource)
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
  func publishComment(content: String?, parentCommentIdentifier: String?, completion: @escaping (_ success: Bool, _ error: CommentsManager.Error?) -> Void) {
    viewModel.publishComment(content: content, parentCommentIdentifier: parentCommentIdentifier) {
      (success, error) in
      completion(success, error)
    }
  }
  
  func wit(commentIdentifier: String, completion: ((_ success: Bool, _ error: CommentsManager.Error?) -> Void)?) {
    viewModel.wit(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion?(success, error)
    }
  }
  
  func unwit(commentIdentifier: String, completion: ((_ success: Bool, _ error: CommentsManager.Error?) -> Void)?) {
    viewModel.unwit(commentIdentifier: commentIdentifier) {
      (success, error) in
      completion?(success, error)
    }
  }
}
