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

    onBoardingNode.delegate = self
    onBoardingNode.dataSource = self
    viewModel.loadOnBoardingData { (success: Bool) in
      self.onBoardingNode.reloadCollection()
    }

    applyTheme()
    applyLocalization()
    observeLanguageChanges()

    navigationItem.backBarButtonItem = UIBarButtonItem.back

    //MARK: [Analytics] Screen Name
    Analytics.shared.send(screenName: Analytics.ScreenNames.OnboardingFollowPeopleAndTopics)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
}

extension OnBoardingViewController: OnBoardingControllerDelegate {
  func continueButtonTouchUpInside(_ sender: Any?) {
    viewModel.completeOnBoarding()
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
      node.text = title.capitalized
      node.isLoading = true
      viewModel.loadOnBoardingCellNodeData(indexPath: indexPath, completionBlock: { [weak self] (indexPath, success, cellCollectionDictionary) in
        guard let strongSelf = self else { return }
        strongSelf.updateNodeForCollectionAtWith(indexPath: indexPath, dictionary: cellCollectionDictionary)
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
      viewModel.follow(identifier: id, resourceType: dataItem.resourceType, completionBlock: { (succes) in
        doneCompletionBlock(succes)
      })
    } else {
      viewModel.unfollow(identifier: id, resourceType: dataItem.resourceType, completionBlock: { (succes) in
        doneCompletionBlock(succes)
      })
    }

    //MARK: [Analytics] Event
    let analyticsAction: Analytics.Action
    switch dataItem.resourceType {
    case Topic.resourceType:
      analyticsAction = shouldSelect ? .FollowTopic : .UnfollowTopic
    case PenName.resourceType:
      analyticsAction = shouldSelect ? .FollowPenName : .UnfollowPenName
    default:
      analyticsAction = shouldSelect ? .Follow : .Unfollow
    }
    let event: Analytics.Event = Analytics.Event(category: .Onboarding,
                                                 action: analyticsAction)
    Analytics.shared.send(event: event)
  }

  func didFinishAnimatingExpansion(of onBoardingCellNode: OnBoardingCellNode) {
    guard let indexPath = onBoardingCellNode.indexPath else {
      return
    }
    onBoardingNode.collectionNode.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.top, animated: true)
  }
}

extension OnBoardingViewController: Themeable {
  func applyTheme() {
    node.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

//MARK: - Localizable implementation
extension OnBoardingViewController: Localizable {
  func applyLocalization() {
    title = Strings.follow_topics()
  }

  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }

  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
