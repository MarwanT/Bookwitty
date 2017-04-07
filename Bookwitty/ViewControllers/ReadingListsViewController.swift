//
//  ReadingListsViewController.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ReadingListsViewController: ASViewController<ASCollectionNode> {
  fileprivate let internalMargin = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing = ThemeManager.shared.currentTheme.contentSpacing()

  fileprivate let collectionNode: ASCollectionNode
  fileprivate let flowLayout: UICollectionViewFlowLayout

  fileprivate let viewModel = ReadingListsViewModel()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionNode.dataSource = self
    collectionNode.delegate = self

    applyLocalization()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.ReadingLists)
  }

  private func initializeComponents() {
    title = Strings.reading_lists()
  }

  func initialize(with lists: [ReadingList]) {
    viewModel.initialize(with: lists)
    collectionNode.reloadData()
  }
}

//MARK: -
extension ReadingListsViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return 1
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItems()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    guard let readingList = viewModel.readingList(at: indexPath.item) else {
      return { ASCellNode() }
    }

    return {
      guard let readingListNode = CardFactory.shared.createCardFor(resource: readingList) else {
        return ASCellNode()
      }
      readingListNode.delegate = self
      return readingListNode
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if let indexPath = collectionNode.indexPath(for: node), indexPath.item % 7 == 0 {
      viewModel.loadNextReadingListPageContent(closure: {
        (success, indices) in
        self.collectionNode.reloadItems(at: indices.map({ IndexPath(item: $0, section: 0) }))
      })
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    let resource = viewModel.resourceForIndex(indexPath: indexPath)
    actionForCard(resource: resource)
  }
}

// MARK - BaseCardPostNode Delegate
extension ReadingListsViewController: BaseCardPostNodeDelegate {
  func cardInfoNode(card: BaseCardPostNode, cardPostInfoNode: CardPostInfoNode, didRequestAction action: CardPostInfoNode.Action, forSender sender: Any) {
    guard let indexPath = collectionNode.indexPath(for: card) else {
      return
    }
    let resource = viewModel.resourceForIndex(indexPath: indexPath)
    if let resource = resource,
      let penName = resource.penName {
      pushProfileViewController(penName: penName)
      
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

      let event: Analytics.Event = Analytics.Event(category: category,
                                                   action: .GoToPenName,
                                                   name: penName.name ?? "")
      Analytics.shared.send(event: event)
    }
  }

  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    guard let indexPath = collectionNode.indexPath(for: card) else {
      return
    }

    switch(action) {
    case .wit:
      viewModel.witContent(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(indexPath: indexPath) { (success) in
        didFinishAction?(success)
      }
    case .share:
      if let sharingInfo: [String] = viewModel.sharingContent(indexPath: indexPath) {
        presentShareSheet(shareContent: sharingInfo)
      }
    default:
      //TODO: handle comment
      break
    }

    //MARK: [Analytics] Event
    guard let resource = viewModel.resourceForIndex(indexPath: indexPath) else { return }
    let category: Analytics.Category = .ReadingList
    let name: String = resource.title ?? ""

    let analyticsAction = Analytics.Action.actionFrom(cardAction: action, with: category)
    let event: Analytics.Event = Analytics.Event(category: category,
                                                 action: analyticsAction,
                                                 name: name)
    Analytics.shared.send(event: event)
  }
}

//MARK: - Localizable implementation
extension ReadingListsViewController: Localizable {
  func applyLocalization() {
    
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}

// MARK: - Actions For Cards
extension ReadingListsViewController {

  fileprivate func actionForCard(resource: ModelResource?) {
    guard let resource = resource else {
      return
    }
    let registeredType = resource.registeredResourceType

    switch registeredType {
    case ReadingList.resourceType:
      actionForReadingListResourceType(resource: resource)
    default:
      print("Type Is Not Registered: \(resource.registeredResourceType) \n Contact Your Admin ;)")
      break
    }
  }

  fileprivate func pushPostDetailsViewController(resource: ModelResource) {
    let nodeVc = PostDetailsViewController(resource: resource)
    self.navigationController?.pushViewController(nodeVc, animated: true)
  }

  fileprivate func actionForReadingListResourceType(resource: ModelResource) {
    //MARK: [Analytics] Event
    let name: String = (resource as? ReadingList)?.title ?? ""
    let event: Analytics.Event = Analytics.Event(category: .ReadingList,
                                                 action: .GoToDetails,
                                                 name: name)
    Analytics.shared.send(event: event)
    pushPostDetailsViewController(resource: resource)
  }
}

