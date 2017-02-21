//
//  NewsFeedViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//
import UIKit
import AsyncDisplayKit

class NewsFeedViewController: ASViewController<ASCollectionNode> {
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let pullToRefresher = UIRefreshControl()

  let viewModel = NewsFeedViewModel()
  let data = ["","","","","","","","","","","","","","",""]
  var isFirstRun: Bool = true

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: externalMargin/2, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()

    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewController
    
    initializeNavigationItems()

    collectionNode.delegate = self
    collectionNode.dataSource = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if isFirstRun {
      isFirstRun = false
      loadData()
    }
  }

  private func initializeNavigationItems() {
    let leftNegativeSpacer = UIBarButtonItem(barButtonSystemItem:
      UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    leftNegativeSpacer.width = -10
    let settingsBarButton = UIBarButtonItem(image: #imageLiteral(resourceName: "person"), style:
      UIBarButtonItemStyle.plain, target: self, action:
      #selector(self.settingsButtonTap(_:)))
    navigationItem.leftBarButtonItems = [leftNegativeSpacer, settingsBarButton]
  }

  func loadData() {
    viewModel.loadNewsfeed { [weak self] (success) in
      guard let strongSelf = self else { return }
      if(success) {
        strongSelf.collectionNode.reloadData()
      }
    }
  }
}

// MARK: - Themeable
extension NewsFeedViewController: Themeable {
  func applyTheme() {
    //TODO: Apply theme here
  }
}

// MARK: - Action
extension NewsFeedViewController {
  func settingsButtonTap(_ sender: UIBarButtonItem) {
    let settingsVC = Storyboard.Account.instantiate(AccountViewController.self)
    settingsVC.hidesBottomBarWhenPushed = true
    self.navigationController?.pushViewController(settingsVC, animated: true)
  }
}

extension NewsFeedViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItemsInSection()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    
    return {
        return self.viewModel.nodeForItem(atIndex: index) ?? BaseCardPostNode()
    }
  }
}

extension NewsFeedViewController: ASCollectionDelegate {
  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
}
