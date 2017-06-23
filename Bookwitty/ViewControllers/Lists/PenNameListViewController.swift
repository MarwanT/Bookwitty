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

  fileprivate let viewModel = PenNameListViewModel()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }

  func initialize(with penNames: [PenName]) {
    viewModel.initialize(with: penNames)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.PenNameList)
  }

  fileprivate func initializeComponents() {
    collectionNode.delegate = self
    collectionNode.dataSource = self

    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.sectionHeadersPinToVisibleBounds = true
  }
}

extension PenNameListViewController: ASCollectionDataSource, ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfPenNames()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      let node = PenNameFollowNode()
      node.delegate = self
      node.showBottomSeparator = true
      return node
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let cell = node as? PenNameFollowNode else {
        return
    }

    let values = viewModel.values(at: indexPath.item)
    cell.penName = values?.penName
    cell.biography = values?.biography
    cell.imageUrl = values?.imageUrl
    cell.following = values?.following ?? false
    cell.updateMode(disabled: values?.isMyPenName ?? false)
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    //TODO: push the pen name details vc
  }
}

//MARK: - PenNameFollowNodeDelegate implementation
extension PenNameListViewController: PenNameFollowNodeDelegate {
  func penName(node: PenNameFollowNode, actionButtonTouchUpInside button: ButtonWithLoader) {

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
    
  }
}
