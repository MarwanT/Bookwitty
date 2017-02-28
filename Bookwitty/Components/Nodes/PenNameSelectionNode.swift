//
//  PenNameSelectionNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

protocol PenNameSelectionNodeDelegate {
  func didSelectPenName(penName: PenName, sender: PenNameSelectionNode)
}

class PenNameSelectionNode: ASCellNode {
  fileprivate static let cellHeight: CGFloat = 45.0
  fileprivate let maxNumberOfCells: Int = 5
  fileprivate let minNumberOfCells: Int = 1
  fileprivate let separatorHeight: CGFloat = 1.0
  fileprivate let collapsedHeightDimension: ASDimension = ASDimension(unit: ASDimensionUnit.points, value: PenNameSelectionNode.cellHeight)
  fileprivate var expandedHeightDimension: ASDimension {
      guard data.count > minNumberOfCells else {
        return ASDimension(unit: ASDimensionUnit.points, value: 0.0)
      }

      let itemHeight = collapsedHeightDimension.value
      let actualNumberOfCells = (maxNumberOfCells > data.count) ? data.count : maxNumberOfCells
      let expandedHeight = itemHeight + (itemHeight * CGFloat(actualNumberOfCells))

      return ASDimension(unit: ASDimensionUnit.points, value: expandedHeight)
  }
  fileprivate var expandedCollectionHeight: CGFloat {
      guard data.count > minNumberOfCells else {
        return 0.0
      }

      return expandedHeightDimension.value - PenNameSelectionNode.cellHeight
  }

  fileprivate let header: PenNameDisplayNode
  fileprivate let lastSeparatorNode: ASDisplayNode
  fileprivate let collectionNode: ASCollectionNode

  private let flowLayout: UICollectionViewFlowLayout
  //Consider replacing expand with DisplayMode enum incase we needed something more than expand and collapse.
  var expand: Bool = true {
    didSet {
      header.updateArrowDirection(direction: expand ? .down : .up)
    }
  }
  fileprivate var data: [PenName] = []
  var delegate: PenNameSelectionNodeDelegate?
  var selectedIndexPath: IndexPath? = nil {
    didSet {
      guard let newValue = selectedIndexPath else {
        return
      }
      guard let oldValue = oldValue else {
        updateSelectedPenName()
        delegate?.didSelectPenName(penName: data[newValue.item], sender: self)
        return
      }

      if oldValue.item != newValue.item {
          updateSelectedPenName()
          delegate?.didSelectPenName(penName: data[newValue.item], sender: self)
      }
    }
  }
  var headerHeight: CGFloat {
      return header.style.height.value
  }
  var occupiedHeight: CGFloat {
      //Subtract separatorHeight from collapsedHeightDimension [So that the view would not be removed the node automatically]
      return expand ? expandedHeightDimension.value : (collapsedHeightDimension.value - separatorHeight)
  }

  override init() {
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    header = PenNameDisplayNode(withCellHeight: PenNameSelectionNode.cellHeight)
    lastSeparatorNode = ASDisplayNode()
    super.init()
    setupNode()
  }

  func setupNode() {
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    collectionNode.delegate = self
    collectionNode.dataSource = self
    automaticallyManagesSubnodes = true

    lastSeparatorNode.style.preferredSize = CGSize(width: style.maxWidth.value, height: separatorHeight)
    lastSeparatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()

    backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    header.delegate = self

    collectionNode.style.preferredSize = CGSize(width: style.maxWidth.value, height: expandedCollectionHeight)
    let extraSeparator = (data.count == 0) ? 0.0 : separatorHeight
    style.height = ASDimensionMake(expandedHeightDimension.value + extraSeparator)
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
//    Commented: Y Transition animation
//    separatorNode.style.width = ASDimensionMake(constrainedSize.max.width)
//    collectionNode.style.width = ASDimensionMake(constrainedSize.max.width)
//    header.style.layoutPosition = CGPoint.init(x: 0, y: 0)
//    separatorNode.style.layoutPosition = CGPoint.init(x: 0, y: 45.0)
//    collectionNode.style.layoutPosition = CGPoint.init(x: 0, y: addAll ? 46.0 : -(CGFloat(self.data.count)*45.0))
//    let nodes: [ASLayoutElement] = addAll ? [collectionNode, separatorNode, header] : [collectionNode, separatorNode, header]
//    let abosoluteLayout = ASAbsoluteLayoutSpec(sizing: ASAbsoluteLayoutSpecSizing.sizeToFit, children: nodes)
//    return abosoluteLayout

    let nodes: [ASLayoutElement] = expand ? [header, collectionNode, lastSeparatorNode] : [header] //
    let verticalStackSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0,
                                              justifyContent: .start,
                                              alignItems: .stretch,
                                              children: nodes)
    return verticalStackSpec
  }

  func updateSelectedPenName() {
    let selectedPenName = data[selectedIndexPath?.item ?? 0]
    header.penNameSummary = Strings.your_feed() + " " + (selectedPenName.name ?? "")
  }

  func loadData(penNames: [PenName]?, withSelected selectedPenName: PenName?) {
    data = penNames ?? []

    guard data.count > minNumberOfCells else {
      style.height = ASDimensionMake(0.0)
      setNeedsLayout()
      return
    }

    expand = true

    if let selectedPenNameId = selectedPenName?.id {
      _ = data.enumerated().filter({ (item: (offset: Int, penName: PenName)) -> Bool in
        guard let id = item.penName.id else {
          return false
        }
        let found = selectedPenNameId == id
        if found {
          self.selectedIndexPath = IndexPath(row: item.offset, section: 0)
        }
        return found
      })
    } else {
      self.selectedIndexPath = IndexPath(row: 0, section: 0)
    }

    updateSelectedPenName()
    let extraSeparator = separatorHeight
    style.height = ASDimensionMake(expandedHeightDimension.value + extraSeparator)

    collectionNode.style.preferredSize = CGSize(width: style.maxWidth.value, height: expandedCollectionHeight)
    collectionNode.reloadData()

    setNeedsLayout()
  }
}

//MARK: - PenNameDisplayNodeDelegate
extension PenNameSelectionNode: PenNameDisplayNodeDelegate {
  func didTapOnHeader(sender: PenNameDisplayNode?) {
    expand = !expand

    let extraSeparator = (data.count == 0) ? 0.0 : separatorHeight
    let heightDimension = expand ? ASDimensionMake(expandedHeightDimension.value + extraSeparator) : collapsedHeightDimension
    style.height = heightDimension

    transitionLayout(withAnimation: true, shouldMeasureAsync: true) {
      //This transition will trigger the node's height change and required change from layoutSpecThatFits
      //In our case the alpha for the collectionNode will change since it is being added and removed from
      //the parent node.
      //TODO: Needed Action When Animation Is Done
    }
  }
}

//MARK: - ASCollectionDataSource | ASCollectionDelegate
extension PenNameSelectionNode: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return data.count > 0 ? 1 : 0
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    let isLast = (index == data.count-1)
    let name: String = data[index].name ?? ""
    return {
      let cell = PenNameCellNode(withSeparator: !isLast, withCellHeight: PenNameSelectionNode.cellHeight)
      cell.penNameSummary = name
      return cell
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {
    guard let indexPath = collectionNode.indexPath(for: node),
      let penNameCellNode = collectionNode.nodeForItem(at: indexPath) as? PenNameCellNode else {
        return
    }
    let selectedIndex = selectedIndexPath?.item ?? -1
    penNameCellNode.select = selectedIndex == indexPath.item
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0.0),
      max: CGSize(width: collectionNode.frame.width, height: PenNameSelectionNode.cellHeight)
    )
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    if let selectedIndexPath = selectedIndexPath,
      let previouslySelectedCellNode = collectionNode.nodeForItem(at: selectedIndexPath) as? PenNameCellNode {
      previouslySelectedCellNode.select = !previouslySelectedCellNode.select
    }
    if let penNameCellNode = collectionNode.nodeForItem(at: indexPath) as? PenNameCellNode {
      selectedIndexPath = indexPath
      penNameCellNode.select = !penNameCellNode.select
    }
  }
}
