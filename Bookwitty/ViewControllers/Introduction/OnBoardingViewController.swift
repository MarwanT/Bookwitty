//
//  OnBoardingViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/2/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingViewController: ASViewController<OnBoardingControllerNode> {
  let onBoardingNode: OnBoardingControllerNode
  let viewModel: OnBoardingViewModel = OnBoardingViewModel()

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    onBoardingNode = OnBoardingControllerNode()
    super.init(node: onBoardingNode)

  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = Strings.follow_topics()
    onBoardingNode.delegate = self
    onBoardingNode.dataSource = self
    viewModel.loadOnBoardingData { (success: Bool) in
      self.onBoardingNode.reloadCollection()
    }
    
    applyTheme()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}

extension OnBoardingViewController: OnBoardingControllerDelegate {
  func continueButtonTouchUpInside(_ sender: Any?) {
    UserManager.shared.shouldDisplayOnboarding = false
    NotificationCenter.default.post(
      name: AppNotification.didFinishBoarding,
      object: nil)
  }
}

extension OnBoardingViewController: OnBoardingControllerDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfOnBoardingTitleSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItems()
  }

  func onBoardingCellNodeTitle(index: Int) -> String {
    return viewModel.onBoardingCellNodeTitle(index: index)
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      let onBoardingCellNode = OnBoardingCellNode()
      return onBoardingCellNode
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode, at indexPath: IndexPath) {
    if let node = node as? OnBoardingCellNode {
      let title = viewModel.onBoardingCellNodeTitle(index: indexPath.row)
      node.delegate = self
      node.text = title
      node.isLoading = true
      _ = viewModel.loadOnBoardingCellNodeData(indexPath: indexPath, completionBlock: { [weak self] (indexPath, success, cellCollectionDictionary) in
        guard let strongSelf = self else { return }
        if success {
          strongSelf.updateNodeForCollectionAtWith(indexPath: indexPath, dictionary: cellCollectionDictionary)
        }
      })
    }
  }

  func updateNodeForCollectionAtWith(indexPath: IndexPath, dictionary: [String : [CellNodeDataItemModel]]?) {
    if let node = onBoardingNode.collectionNode.nodeForItem(at: indexPath) as? OnBoardingCellNode {
      node.setViewModelData(data: dictionary)
      node.isLoading = false
    }
  }
}

extension OnBoardingViewController: OnBoardingCellDelegate {
  func didTapOnSelectionButton(dataItem: CellNodeDataItemModel, internalCollectionNode: ASCollectionNode, indexPath: IndexPath, cell: OnBoardingInternalCellNode, button: OnBoardingLoadingButton, shouldSelect: Bool, doneCompletionBlock: @escaping (_ success: Bool) -> ()) {
    guard let id = dataItem.id else {
      doneCompletionBlock(false)
      return
    }
    if shouldSelect {
      viewModel.followRequest(identifier: id, completionBlock: { (succes) in
        doneCompletionBlock(succes)
      })
    } else {
      viewModel.unfollowRequest(identifier: id, completionBlock: { (succes) in
        doneCompletionBlock(succes)
      })
    }
  }
}

extension OnBoardingViewController: Themeable {
  func applyTheme() {
    node.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}
