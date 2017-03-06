//
//  OnBoardingCellNode.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/3/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class OnBoardingCellNode: ASCellNode {
  fileprivate let internalMargin: CGFloat = ThemeManager.shared.currentTheme.cardInternalMargin()
  fileprivate let contentSpacing: CGFloat = ThemeManager.shared.currentTheme.contentSpacing()
  fileprivate let collapsedCellHeight: CGFloat = 45.0

  fileprivate var expandedCellHeight: CGFloat {
    return  collectionHeight + collapsedCellHeight
  }
  fileprivate var collectionHeight: CGFloat {
    return (CGFloat(data.count) * OnBoardingInternalCellNode.cellHeight)
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

  //TODO: Replace with real data
  var data: [String] = ["Test 1","Test 2","Test 3","Test 4"]
  var sections: [String] = ["Section 1", "Section 2"]

  var showAll: Bool = true {
    didSet {
      let newHeightDimension = ASDimensionMake(showAll ? expandedCellHeight : collapsedCellHeight)
      self.style.height = newHeightDimension
      headerNode.updateArrowDirection(direction: showAll ? .up : .right, animated: true)
      transitionLayout(withAnimation: true, shouldMeasureAsync: false, measurementCompletion: nil)
    }
  }
  var text: String? {
    didSet {
      if let text = text {
        headerNode.text = text
      }
    }
  }

  override init() {
    headerNode = OnBoardingItemHeaderNode()
    flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    flowLayout.minimumInteritemSpacing  = 0
    flowLayout.minimumLineSpacing       = 0
    flowLayout.headerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: 45.0)

    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

    super.init()

    automaticallyManagesSubnodes = true
    style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: expandedCellHeight)

    collectionNode.delegate = self
    collectionNode.dataSource = self
    collectionNode.style.flexGrow = 1.0
    collectionNode.style.flexShrink = 1.0

    showAll = true

    backgroundColor = UIColor.bwNero
  }

  override func didLoad() {
    super.didLoad()
    collectionNode.registerSupplementaryNode(ofKind: UICollectionElementKindSectionHeader)
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
    }
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let vStack = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start,
                                   alignItems: .stretch, children: showAll ? [headerNode, collectionNode] : [headerNode])

    return vStack
  }
}

extension OnBoardingCellNode: ASCollectionDelegate, ASCollectionDataSource {

  func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
    let cell = OnBoardingCellSectionNode()
    cell.text = "Topics to Follow"
    return cell
  }

  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return sections.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    let isLast = index == (data.count - 1)
    return {
      let cell = OnBoardingInternalCellNode()
      cell.text = "\(index) User Experience Design"
      cell.descriptionText = "A page top share interesting books or articles related to UX design, and design thinking."
      cell.isLast = isLast
      cell.delegate = self
      return cell
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
  func didTapOnSelectionButton(cell: OnBoardingInternalCellNode, button: OnBoardingLoadingButton, isSelected: Bool, doneCompletionBlock: @escaping (_ success: Bool) -> ()) {
    //TODO: Do needed action
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(4)) {
      doneCompletionBlock(true)
    }
  }
}
