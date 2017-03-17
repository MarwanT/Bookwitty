//
//  ProfileDetailsViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 3/17/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import AsyncDisplayKit

class ProfileDetailsViewController: ASViewController<ASCollectionNode> {
  let flowLayout: UICollectionViewFlowLayout
  let collectionNode: ASCollectionNode
  let penNameHeaderNode: PenNameFollowNode
  fileprivate var segmentedNode: SegmentedControlNode

  fileprivate var viewModel: ProfileDetailsViewModel!
  fileprivate var segments: [Segment] = [.latest(index: 0), .followers(index: 1), .following(index: 2)]
  fileprivate var activeSegment: Segment

  class func create(with viewModel: ProfileDetailsViewModel) -> ProfileDetailsViewController {
    let profileVC = ProfileDetailsViewController()
    profileVC.viewModel = viewModel
    return profileVC
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private init() {
    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    segmentedNode = SegmentedControlNode()
    activeSegment = segments[0]
    penNameHeaderNode = PenNameFollowNode(enlarged: true)
    super.init(node: collectionNode)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeComponents()
    collectionNode.dataSource = self
    collectionNode.delegate = self
    applyTheme()
  }

  private func initializeComponents() {

    initializeHeader()

    segmentedNode.initialize(with: segments.map({ $0.name }))
    segmentedNode.selectedSegmentChanged = segmentedNode(segmentedControlNode:didSelectSegmentIndex:)
    segmentedNode.style.preferredSize = CGSize(width: collectionNode.style.maxWidth.value, height: 45.0)
  }

  private func initializeHeader() {
    penNameHeaderNode.showBottomSeparator = false
    penNameHeaderNode.biography = viewModel.penName.biography
    penNameHeaderNode.penName = viewModel.penName.name
    penNameHeaderNode.following = viewModel.penName.following
    penNameHeaderNode.imageUrl = viewModel.penName.avatarUrl
  }

  private func segmentedNode(segmentedControlNode: SegmentedControlNode, didSelectSegmentIndex index: Int) {
    collectionNode.reloadSections(IndexSet(integer: Section.cells.rawValue))
  }
}

extension ProfileDetailsViewController: ASCollectionDelegate {
  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    //TODO: actions
  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
}

extension ProfileDetailsViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    //TODO: replace with real value
    return 0
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    //TODO: replace with real value
    return 0
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      //TODO: use real cells
      return ASCellNode()
    }
  }

}

extension ProfileDetailsViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
  }
}

// MARK: - Declarations
extension ProfileDetailsViewController {
  enum Section: Int {
    case profileInfo = 0
    case segmentedControl
    case cells
    case activityIndicator

    static var numberOfSections: Int {
      return 4
    }
  }

  enum Segment {
    case latest(index: Int)
    case followers(index: Int)
    case following(index: Int)
    case none

    //TODO: Should be localized
    var name: String {
      switch self {
      case .latest:
        return "Latest"
      case .followers:
        return Strings.followers()
      case .following:
        return "Editions"
      case .none:
        return ""
      }
    }

    var index: Int {
      switch self {
      case .latest(let index):
        return index
      case .followers(let index):
        return index
      case .following(let index):
        return index
      case .none:
        return NSNotFound
      }
    }
  }

  fileprivate func category(withIndex index: Int) -> Segment {
    guard let segment = self.segments.filter({ $0.index == index }).first else {
      return .none
    }

    return segment
  }
}
