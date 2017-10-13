//
//  PostPreviewViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/10/06.
//  Copyright © 2017 Keeward. All rights reserved.
//

import AsyncDisplayKit

protocol PostPreviewViewControllerDelegate: class {
  //TODO: Modify signature, Replace `Any` with the correct model once there
  func postPreview(viewController: PostPreviewViewController, didFinishPreviewing post: Any)
}

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

  let viewModel = PostPreviewViewModel()

  weak var delegate: PostPreviewViewControllerDelegate?
  
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
    setupNavigationBarButtons()
  }

  fileprivate func initializeComponents() {

    title = Strings.post_preview()

    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0

    collectionNode.delegate = self
    collectionNode.dataSource = self

    titleNode.delegate = self
    coverNode.delegate = self
  }

  fileprivate func setupNavigationBarButtons() {
    navigationItem.backBarButtonItem = UIBarButtonItem.back

    let doneBarButtonItem = UIBarButtonItem(title: Strings.done(),
                                            style: UIBarButtonItemStyle.plain,
                                            target: self,
                                            action: #selector(self.doneBarButtonTouchUpInside(_:)))
    doneBarButtonItem.tintColor = ThemeManager.shared.currentTheme.defaultButtonColor()
    navigationItem.rightBarButtonItem = doneBarButtonItem
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
      return 1
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

    titleNode.resignFirstResponder()
    descriptionNode.resignFirstResponder()

    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.allowsEditing = true
    self.navigationController?.present(imagePickerController, animated: true, completion: nil)
  }
}

//MARK: - EditableTextNodeDelegate implementation
extension PostPreviewViewController: EditableTextNodeDelegate {
  func editableTextNodeDidFinishEditing(textNode: EditableTextNode) {
    viewModel.candidatePost.title = textNode.contentText
  }

  func editableTextNodeDidRequestClear(textNode: EditableTextNode) {
    viewModel.candidatePost.title = nil
    textNode.text = nil
    shouldShowTitle = false
    collectionNode.reloadData()
  }
}

extension PostPreviewViewController: LimitedEditableTextNodeDelegate {
  func limitedEditableTextNodeDidFinishEditing(textNode: LimitedEditableTextNode) {
    viewModel.candidatePost.shortDescription = textNode.contentText
  }
}

//MARK: - CoverPhotoNodeDelegate implementation
extension PostPreviewViewController: CoverPhotoNodeDelegate {
  func coverPhoto(node: CoverPhotoNode, didRequest action: CoverPhotoNode.Action) {
    switch action {
    case .gallery:
      self.presentImagePicker()
    case .delete:
      self.viewModel.candidatePost.imageUrl = nil
      shouldShowCover = false
      collectionNode.reloadData()
    }
  }
}

//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate implementation
extension PostPreviewViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      return
    }

    viewModel.upload(image: image) {
      (success: Bool, url: String?) in
      guard success else {
        //TODO: should we alert the user ?
        self.navigationController?.dismiss(animated: true, completion: nil)
        return
      }
      
      self.viewModel.candidatePost.imageUrl = url
      self.shouldShowCover = true
      self.coverNode.url = url
      self.collectionNode.reloadData()

      self.navigationController?.dismiss(animated: true, completion: nil)
    }
  }
}
