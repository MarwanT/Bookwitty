//
//  PenNameListViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 6/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PenNameListViewController: ASViewController<ASCollectionNode> {

  fileprivate let collectionNode: ASCollectionNode
  fileprivate var flowLayout: UICollectionViewFlowLayout

  fileprivate let loaderNode: LoaderNode

  fileprivate let viewModel = PenNameListViewModel()

  var loadingStatus: LoadingStatus = .none  
  var shouldShowLoader: Bool {
    return loadingStatus != .none
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    loaderNode = LoaderNode()
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  func initializeWith(penNames: [PenName]) {
    viewModel.initialize(with: penNames)
  }

  func initializeWith(resource: ModelResource) {
    viewModel.initialize(with: resource)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.PenNameList)

    loadingStatus = .loading
    viewModel.getVoters { (success: Bool) in
      self.loadingStatus = .none
      self.collectionNode.reloadData()
    }
  }

  fileprivate func initializeComponents() {
    collectionNode.delegate = self
    collectionNode.dataSource = self

    loaderNode.style.preferredSize.width = collectionNode.frame.width

    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true
  }
}

// MARK: - Declarations
extension PenNameListViewController {
  enum LoadingStatus {
    case none
    case loadMore
    case loading
  }

  enum Section: Int {
    case penNames
    case activityIndicator
    static var numberOfSections: Int {
      return 2
    }
  }
}

//MARK: - ASCollectionDataSource, ASCollectionDelegate implementations
extension PenNameListViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return Section.numberOfSections
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    switch section  {
    case Section.penNames.rawValue:
      return viewModel.numberOfPenNames()
    case Section.activityIndicator.rawValue:
      return shouldShowLoader ? 1 : 0
    default:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let section = indexPath.section
    return {
      if case section = Section.activityIndicator.rawValue {
        return self.loaderNode
      } else if case section = Section.penNames.rawValue {
        let node = PenNameFollowNode()
        node.delegate = self
        node.showBottomSeparator = true
        return node
      } else {
        return ASCellNode()
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node) else {
        return
    }

    if case indexPath.section = Section.activityIndicator.rawValue {
      guard let loaderNode = node as? LoaderNode else {
        return
      }

      loaderNode.updateLoaderVisibility(show: shouldShowLoader)
    } else if case indexPath.section = Section.penNames.rawValue {

      guard let cell = node as? PenNameFollowNode else {
          return
      }

      let values = viewModel.values(at: indexPath.item)
      cell.penName = values?.penName
      cell.biography = values?.biography
      cell.imageUrl = values?.imageUrl
      cell.following = values?.following ?? false
      cell.showMoreButton = !(values?.isMyPenName ?? false)
      cell.updateMode(disabled: values?.isMyPenName ?? false)
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    //TODO: push the pen name details vc
  }

  public func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    return viewModel.hasNextPage()
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
    guard context.isFetching() else {
      return
    }

    guard loadingStatus == .none else {
      context.completeBatchFetching(true)
      return
    }
    
    self.loadingStatus = .loadMore
    context.beginBatchFetching()

    viewModel.getNextPage { (success: Bool) in
      self.loadingStatus = .none
      collectionNode.reloadData()
      context.completeBatchFetching(true)
    }
  }
}

//MARK: - PenNameFollowNodeDelegate implementation
extension PenNameListViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ButtonWithLoader) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let penName = viewModel.penName(at: indexPath.item) else {
      return
    }

    button.state = .loading

    if penName.following {
      viewModel.unfollow(at: indexPath.item, completionBlock: {
        (success: Bool) in
        node.following = !success
        button.state = success ? .normal : .selected
      })
    } else {
      viewModel.follow(at: indexPath.item, completionBlock: {
        (success: Bool) in
        node.following = success
        button.state = success ? .selected : .normal
      })
    }

    //MARK: [Analytics] Event
    let analyticsAction: Analytics.Action = penName.following ? .UnfollowPenName : .FollowPenName
    let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                 action: analyticsAction,
                                                 name: penName.name ?? "")
    Analytics.shared.send(event: event)
  }
  
  func penName(node: PenNameFollowNode, actionPenNameFollowTouchUpInside button: Any?) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let penName = viewModel.penName(at: indexPath.item) else {
        return
    }
    pushProfileViewController(penName: penName)

    //MARK: [Analytics] Event
    let event: Analytics.Event = Analytics.Event(category: .PenName,
                                                 action: .GoToDetails,
                                                 name: penName.name ?? "")
    Analytics.shared.send(event: event)
  }

  func penName(node: PenNameFollowNode, requestToViewImage image: UIImage, from imageNode: ASNetworkImageNode){    
    penName(node: node, actionPenNameFollowTouchUpInside: imageNode)
  }

  func penName(node: PenNameFollowNode, moreButtonTouchUpInside button: ASButtonNode?) {
    
    guard let indexPath = collectionNode.indexPath(for: node),
      let identifier = viewModel.penName(at: indexPath.row)?.id else {
        return
    }

    self.showMoreActionSheet(identifier: identifier, actions: [.report(.penName)], completion: {
      (success: Bool) in

    })
  }
}
