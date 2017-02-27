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
  let penNameSelectionNode = PenNameSelectionNode()

  let scrollingThreshold: CGFloat = 25.0
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

    super.init(node: collectionNode)

    collectionNode.onDidLoad { [weak self] (collectionNode) in
      guard let strongSelf = self,
        let collectionView = collectionNode.view as? ASCollectionView else {
          return
      }
      collectionView.addSubview(strongSelf.pullToRefresher)
      collectionView.alwaysBounceVertical = true
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = viewModel.viewController
    addObservers()
    initializeNavigationItems()

    collectionNode.delegate = self
    collectionNode.dataSource = self
    penNameSelectionNode.delegate = self
    //Listen to pullToRefresh valueChange and call loadData
    pullToRefresher.addTarget(self, action: #selector(self.loadData), for: .valueChanged)

    applyTheme()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if isFirstRun && UserManager.shared.isSignedIn {
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

  func loadData(withPenNames reloadPenNames: Bool = true) {
    pullToRefresher.beginRefreshing()
    viewModel.loadNewsfeed { [weak self] (success) in
      guard let strongSelf = self else { return }
      strongSelf.pullToRefresher.endRefreshing()
      strongSelf.collectionNode.reloadData(completion: { 
        if reloadPenNames {
          strongSelf.reloadPenNamesNode()
        }
      })
    }
  }

  func reloadPenNamesNode() {
    penNameSelectionNode.loadData(penNames: viewModel.penNames, withSelected: viewModel.defaultPenName)
  }
}
extension NewsFeedViewController: PenNameSelectionNodeDelegate {
  func didSelectPenName(penName: PenName, sender: PenNameSelectionNode) {
    viewModel.didUpdateDefaultPenName(penName: penName, completionBlock: {
      loadData(withPenNames: false)
    })
  }
}
// MARK: - Notification
extension NewsFeedViewController {
  func addObservers() {
    NotificationCenter.default.addObserver(self, selector:
      #selector(self.didSignInNotification(notification:)), name: AppNotification.didSignIn, object: nil)
  }

  func didSignInNotification(notification: Notification) {
    //User signed in or changed: Reset isFirstRun to make sure data reloads
    isFirstRun = true
  }
}
// MARK: - Themeable
extension NewsFeedViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    pullToRefresher.tintColor = ThemeManager.shared.currentTheme.colorNumber19()
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
      if(index != 0) {
        let baseCardNode = self.viewModel.nodeForItem(atIndex: index) ?? BaseCardPostNode()
        baseCardNode.delegate = self
        return baseCardNode
      } else {
        return self.penNameSelectionNode
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is PenNameSelectionNode {
      penNameSelectionNode.setNeedsLayout()
    }
  }
}

// MARK - BaseCardPostNode Delegate
extension NewsFeedViewController: BaseCardPostNodeDelegate {
  func cardActionBarNode(card: BaseCardPostNode, cardActionBar: CardActionBarNode, didRequestAction action: CardActionBarNode.Action, forSender sender: ASButtonNode, didFinishAction: ((_ success: Bool) -> ())?) {
    guard let index = collectionNode.indexPath(for: card)?.item else {
      return
    }

    switch(action) {
    case .wit:
      viewModel.witContent(index: index) { (success) in
        didFinishAction?(success)
      }
    case .unwit:
      viewModel.unwitContent(index: index) { (success) in
        didFinishAction?(success)
      }
    default:
      //TODO: handle comment and share actions
      break
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

extension NewsFeedViewController: UIScrollViewDelegate {
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollToTheRightPosition(scrollView: scrollView)
  }

  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if(!decelerate) {
      scrollToTheRightPosition(scrollView: scrollView)
    }
  }

  private func scrollToTheRightPosition(scrollView: UIScrollView) {
    let penNameHeight = penNameSelectionNode.occupiedHeight
    if scrollView.contentOffset.y <= penNameHeight {
      if(scrollView.contentOffset.y <= scrollingThreshold) {
        UIView.animate(withDuration: 0.3, animations: {
          self.penNameSelectionNode.alpha = 1.0
          scrollView.contentOffset = CGPoint(x: 0, y: 0.0)
          //TODO: use inset to hide the bar:
          //scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        })
      } else {
        UIView.animate(withDuration: 0.3, animations: {
          self.penNameSelectionNode.alpha = 0.4
          scrollView.contentOffset = CGPoint(x: 0, y: penNameHeight)
          //TODO: use inset to hide the bar:
          //scrollView.contentInset = UIEdgeInsets(top: -penNameHeight, left: 0, bottom: 0, right: 0)
        })
      }
    }
  }
}
