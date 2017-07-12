//
//  OnBoardingCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol OnBoardingCellDelegate: class {
  func didTapOnSelectionButton(dataItem: CellNodeDataItemModel, internalCollectionNode collectioNode: ASCollectionNode, indexPath: IndexPath, cell: OnBoardingInternalCellNode, button: OnBoardingLoadingButton, shouldSelect: Bool, doneCompletionBlock: @escaping (_ success: Bool) -> ())
   func didFinishAnimatingExpansion(of onBoardingCellNode: OnBoardingCellNode)
}

class OnBoardingCellNode: ASCellNode {
  enum State {
    case expanded
    case collapsed
  }

  fileprivate let internalMargin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing: CGFloat = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let collapsedCellHeight: CGFloat = 45.0
  fileprivate static let sectionHeight: CGFloat = 45.0

  fileprivate var expandedCellHeight: CGFloat {
    return  collectionHeight + collapsedCellHeight
  }
  fileprivate var collectionHeight: CGFloat {
    return (CGFloat(viewModel.numberOfSubItems()) * OnBoardingInternalCellNode.cellHeight) + (OnBoardingCellNode.sectionHeight * CGFloat(viewModel.numberOfSections()))
  }
  fileprivate var collapsedFinalFrame: CGRect {
    return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: collapsedCellHeight)
  }
  fileprivate var expandedFinalFrame: CGRect {
    return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: expandedCellHeight)
  }

  let headerNode: OnBoardingItemHeaderNode
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout

  fileprivate var viewModel: OnBoardingCellNodeViewModel = OnBoardingCellNodeViewModel()
  weak var delegate: OnBoardingCellDelegate?
  var showAll: Bool = false
  var state: State = .collapsed
  var text: String? {
    didSet {
      if let text = text {
        headerNode.text = text
      }
    }
  }
  var isLoading: Bool = false {
    didSet {
      headerNode.isLoading = isLoading
    }
  }

  override init() {
    headerNode = OnBoardingItemHeaderNode()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: OnBoardingCellNode.sectionHeight)

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

    super.init()

    automaticallyManagesSubnodes = true
    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: collapsedCellHeight)

    collectionNode.delegate = self
    collectionNode.dataSource = self
    collectionNode.style.width = ASDimensionMake(UIScreen.main.bounds.width)
    collectionNode.style.flexGrow = 1.0
    collectionNode.style.flexShrink = 1.0
  }

  override func didLoad() {
    super.didLoad()
    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
    updateViewState(state: .collapsed)
  }
  
  override func animateLayoutTransition(_ context: ASContextTransitioning) {
    let finalFrame = showAll ? expandedFinalFrame : collapsedFinalFrame

    let finalCollectionFrame = CGRect(x: 0,
                                      y: showAll ? collapsedCellHeight : -collapsedCellHeight/2,
                                      width: UIScreen.main.bounds.width,
                                      height: collectionHeight)

    UIView.animate(withDuration: 0.30, animations: {
      self.view.sendSubview(toBack: self.collectionNode.view)
      self.collectionNode.frame = finalCollectionFrame
      self.frame = finalFrame
    }) { (success) in
      context.completeTransition(true)
      if self.showAll {
        self.delegate?.didFinishAnimatingExpansion(of: self)
      }
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start,
                                   alignItems: .stretch, children: showAll ? [headerNode, collectionNode] : [headerNode])

    return vStack
  }

  func setViewModelData(data: [String : [CellNodeDataItemModel]]?) {
    viewModel.data = data ?? [:]
    collectionNode.reloadData()
  }

  func updateViewState(state: State) {
    guard state == .collapsed || !headerNode.isLoading else {
      return
    }
    showAll = state == .expanded
    let newHeight = showAll ? expandedCellHeight : collapsedCellHeight
    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: newHeight)
    headerNode.updateArrowDirection(direction: showAll ? .up : .right, animated: true)
    transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
  }
}

extension OnBoardingCellNode: ASCollectionDelegate, ASCollectionDataSource {

  func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    let cell = OnBoardingCellSectionNode()
    cell.text = viewModel.onBoardingCellNodeTitle(index: indexPath.section)
    return cell
  }

  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return viewModel.numberOfSections()
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return viewModel.numberOfItemsInSections(section: section)
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let isLast = viewModel.isLastItemInSection(indexPath: indexPath)
    return {
      let cell = OnBoardingInternalCellNode()
      cell.isLast = isLast
      cell.delegate = self
      return cell
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let node = node as? OnBoardingInternalCellNode else {
        return
    }
    let item: CellNodeDataItemModel? = viewModel.onBoardingCellNodeSectionItem(indexPath: indexPath)
    node.following = item?.following
    node.text = item?.shortDescription ?? ""
    node.descriptionText = item?.longDescription ?? ""
    if let url = item?.imageUrl {
      node.imageNode.url = URL(string: url)
    }
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: OnBoardingInternalCellNode.cellHeight),
      max: CGSize(width: collectionNode.frame.width, height: OnBoardingInternalCellNode.cellHeight)
    )
  }
}

extension OnBoardingCellNode: OnBoardingInternalCellNodeDelegate {
  func didTapOnSelectionButton(cell: OnBoardingInternalCellNode, button: OnBoardingLoadingButton, shouldSelect: Bool, doneCompletionBlock: @escaping (_ success: Bool) -> ()) {
    guard let indexPath = collectionNode.indexPath(for: cell) else {
      doneCompletionBlock(false)
      return
    }
    guard let dataItem: CellNodeDataItemModel = viewModel.onBoardingCellNodeSectionItem(indexPath: indexPath) else {
      doneCompletionBlock(false)
        return
    }
    delegate?.didTapOnSelectionButton(dataItem: dataItem, internalCollectionNode: collectionNode, indexPath: indexPath, cell: cell, button: button, shouldSelect: shouldSelect, doneCompletionBlock: doneCompletionBlock)
  }
}

final class OnBoardingCellNodeViewModel {
  var data: [String : [CellNodeDataItemModel]] = [:]

  func onBoardingCellNodeSectionItems(section: Int) -> [CellNodeDataItemModel] {
    let dataArray = Array(data.keys)
    guard (section >= 0 && section < dataArray.count) else {
      return []
    }

    let key = dataArray[section]
    return data[key] ?? []
  }

  func numberOfSections() -> Int {
    return data.count
  }

  func numberOfItemsInSections(section: Int) -> Int {
    return onBoardingCellNodeSectionItems(section: section).count
  }

  func onBoardingCellNodeTitle(index: Int) -> String {
    let dataArray = Array(data.keys)
    guard (index >= 0 && index < dataArray.count) else {
      return ""
    }

    let item = dataArray[index]
    return item
  }

  func onBoardingCellNodeSectionItem(indexPath: IndexPath) -> CellNodeDataItemModel? {
    let section = indexPath.section
    let index = indexPath.item
    let itemsInSection = onBoardingCellNodeSectionItems(section: section)
    guard itemsInSection.count > 0 && index < itemsInSection.count else {
      return nil
    }
    return itemsInSection[index]
  }

  func isLastItemInSection(indexPath: IndexPath) -> Bool {
    return (onBoardingCellNodeSectionItems(section: indexPath.section).count - 1) == indexPath.item
  }


  func numberOfSubItems() -> Int {
    var count = 0
    for (_,value) in data {
      count += value.count
    }
    return count
  }
}
