//
//  TagFeedViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/08/10.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TagFeedViewController: ASViewController<ASCollectionNode> {

  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout
  let loaderNode: LoaderNode

  fileprivate let viewModel = TagFeedViewModel()


  fileprivate var loadingStatus: LoadingStatus = .none
  fileprivate var shouldShowLoader: Bool {
    return (loadingStatus != .none && loadingStatus != .reloading)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets.zero
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    loaderNode = LoaderNode()

    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }
}

// MARK: - Declarations
extension TagFeedViewController {
  enum LoadingStatus {
    case none
    case loadMore
    case reloading
    case loading
  }

  enum Section: Int {
    case cards
    case activityIndicator

    static var numberOfSections: Int {
      return 2
    }
  }
}

//MARK: ASCollectionDataSource, ASCollectionDelegate implementation
extension TagFeedViewController: ASCollectionDataSource, ASCollectionDelegate {
  private func nodeForItem(atIndex index: Int) -> BaseCardPostNode? {
    guard let resource = self.viewModel.resourceForIndex(index: index) else {
      return nil
    }

    let card = CardFactory.createCardFor(resourceType: resource.registeredResourceType)
    card?.baseViewModel?.resource = resource as? ModelCommonProperties
    return card
  }


  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return Section.numberOfSections
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case TagFeedViewController.Section.cards.rawValue:
      return self.viewModel.data.count
    case TagFeedViewController.Section.activityIndicator.rawValue:
      return shouldShowLoader ? 1 : 0
    default:
      return 0
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    let section = indexPath.section
    return {
      if section == Section.cards.rawValue {
        let baseCardNode = self.nodeForItem(atIndex: index) ?? BaseCardPostNode()
        return baseCardNode
      } else if section == Section.activityIndicator.rawValue {
        return self.loaderNode
      } else {
        return ASCellNode()
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    if node is LoaderNode {
      loaderNode.updateLoaderVisibility(show: shouldShowLoader)
    } else if let card = node as? BaseCardPostNode {
      guard let indexPath = collectionNode.indexPath(for: node),
        let resource = viewModel.resourceForIndex(index: indexPath.row), let commonResource =  resource as? ModelCommonProperties else {
          return
      }

      if let sameInstance = card.baseViewModel?.resource?.sameInstanceAs(newResource: commonResource), !sameInstance {
        card.baseViewModel?.resource = commonResource
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard indexPath.section == Section.cards.rawValue else {
      return
    }

    //TODO: do action
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
}
