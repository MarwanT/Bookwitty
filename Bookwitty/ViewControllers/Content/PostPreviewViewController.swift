//
//  PostPreviewViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/06.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

class PostPreviewViewController: ASViewController<ASCollectionNode> {

  enum Sections: Int {
    case customize
    case penName
    case cover
    case title
    case description
    case newCover
    case newTitle

    static let count: Int = 7
  }

  fileprivate let penNameNode: PenNameCellNode
  fileprivate let titleNode: EditableTextNode
  fileprivate let descriptionNode: LimitedEditableTextNode
  fileprivate let coverNode: CoverPhotoNode

  fileprivate var flowLayout: UICollectionViewFlowLayout
  fileprivate let collectionNode: ASCollectionNode

  fileprivate var shouldShowTitle: Bool = false
  fileprivate var shouldShowCover: Bool = false
  
  init() {
    penNameNode = PenNameCellNode(withSeparator: false, withCellHeight: 45.0)
    titleNode = EditableTextNode()
    descriptionNode = LimitedEditableTextNode()
    coverNode = CoverPhotoNode()

    flowLayout = UICollectionViewFlowLayout()
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
    super.init(node: collectionNode)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initializeComponents()
    applyTheme()
  }

  fileprivate func initializeComponents() {
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode.delegate = self
    collectionNode.dataSource = self

    coverNode.delegate = self
  }
}

//MARK: - Actions
extension PostPreviewViewController {
  @objc fileprivate func doneBarButtonTouchUpInside(_ sender: UIBarButtonItem) {
    //TODO: Empty implementation
  }
}

//MARK: - Themeable implementation
extension PostPreviewViewController: Themeable {
  func applyTheme() {
    collectionNode.backgroundColor = ThemeManager.shared.currentTheme.colorNumber2()
    penNameNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
    coverNode.backgroundColor = ThemeManager.shared.currentTheme.defaultBackgroundColor()
  }
}

extension PostPreviewViewController: ASCollectionDataSource, ASCollectionDelegate {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return Sections.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    guard let section = Sections(rawValue: section) else {
      return 0
    }

    switch section {
    case .customize:
      return 3 // sep - node - sep
    case .penName:
      return 2 // node - sep
    case .cover:
      return shouldShowCover ? 1 : 0 //node
    case .title:
      return shouldShowTitle ? 2 : 0 //node
    case .description:
      return 0
    case .newCover:
      return shouldShowCover ? 0 : 1 //shows only if no cover
    case .newTitle:
      return shouldShowTitle ? 0 : 1 //shows only if no title
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
      guard let section = Sections(rawValue: indexPath.section) else {
        return ASCellNode()
      }

      switch section {
      case .customize:
        switch indexPath.row {
        case 1:
          return self.createCustomizeCellNode()
        default:
          return self.createSeparatorNode()
        }
      case .penName:
        switch indexPath.row {
        case 0:
          return self.penNameNode
        default:
          return self.createSeparatorNode()
        }
      case .cover:
        return self.coverNode
      case .title:
        switch indexPath.row {
        case 0:
          return self.titleNode
        default:
          return self.createSeparatorNode()
        }
      case .description:
        return self.descriptionNode
      case .newCover:
        return self.createAddImageCellNode()
      case .newTitle:
        return self.createAddTitleCellNode()
      }
    }
  }

  func collectionNode(_ collectionNode: ASCollectionNode, willDisplayItemWith node: ASCellNode) {

  }

  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }

  func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
    guard let section = Sections(rawValue: indexPath.section) else {
      return
    }

    switch section {
    case .newCover:
      self.presentImagePicker()
    case .newTitle:
      shouldShowTitle = !shouldShowTitle
      collectionNode.reloadData(completion: {
        if self.shouldShowTitle {
          self.titleNode.textNode.becomeFirstResponder()
        }
      })
    default:
      break
    }
  }

  fileprivate func createSeparatorNode() -> ASCellNode {
    let separatorNode = ASCellNode()
    separatorNode.style.height = ASDimensionMake(1)
    separatorNode.style.flexGrow = 0.0
    separatorNode.style.flexShrink = 1
    separatorNode.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    return separatorNode
  }

  fileprivate func createCustomizeCellNode() -> ASCellNode {
    let node = ASCellNode()
    node.automaticallyManagesSubnodes = true
    node.style.flexGrow = 1.0
    node.style.height = ASDimension(unit: .points, value: 45.0)
    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: Strings.customize_your_posts_card(), color: ThemeManager.shared.currentTheme.defaultTextColor())
        .attributedString
      let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
      return centerSpec
    }
    return node
  }

  fileprivate func createAddImageCellNode() -> ASCellNode {
    let node = ASCellNode()
    node.automaticallyManagesSubnodes = true
    node.style.flexGrow = 1.0
    node.style.height = ASDimension(unit: .points, value: 45.0)
    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: Strings.add_an_image(), color: ThemeManager.shared.currentTheme.defaultButtonColor())
        .attributedString
      let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
      return centerSpec
    }
    return node
  }

  fileprivate func createAddTitleCellNode() -> ASCellNode {
    let node = ASCellNode()
    node.automaticallyManagesSubnodes = true
    node.style.flexGrow = 1.0
    node.style.height = ASDimension(unit: .points, value: 45.0)
    node.layoutSpecBlock = { (node: ASDisplayNode, constrainedSize: ASSizeRange) -> ASLayoutSpec in
      let textNode = ASTextNode()
      textNode.attributedText = AttributedStringBuilder(fontDynamicType: .caption2)
        .append(text: Strings.add_a_title(), color: ThemeManager.shared.currentTheme.defaultButtonColor())
        .attributedString
      let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: .minimumXY, child: textNode)
      return centerSpec
    }
    return node
  }

  fileprivate func presentImagePicker() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.allowsEditing = true
    self.navigationController?.present(imagePickerController, animated: true, completion: nil)
  }
}

//MARK: - CoverPhotoNodeDelegate implementation
extension PostPreviewViewController: CoverPhotoNodeDelegate {
  func coverPhoto(node: CoverPhotoNode, didRequest action: CoverPhotoNode.Action) {
    //TODO: Empty implementation
  }
}

//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate implementation
extension PostPreviewViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      return
    }

    //TODO: use the image
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}
