//
//  BookStoreViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/13/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import FLKAutoLayout

class BookStoreViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  
  let viewModel = BookStoreViewModel()
  
  fileprivate let leftMargin = ThemeManager.shared.currentTheme.generalExternalMargin()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let didAddBanner = loadBannerSection()
    let didAddFeaturedSection = loadFeaturedContentSection()
    addSeparator(leftMargin)
    let didAddViewAllCategoriesSection = loadViewAllCategories()
    addSeparator()
  }
  
  func loadBannerSection() -> Bool {
    let banner = Banner()
    banner.image = #imageLiteral(resourceName: "Illustrtion")
    banner.title = "Bookwitty's Finest"
    banner.subtitle = "The perfect list for everyone on your list"
    stackView.addArrangedSubview(banner)
    return true
  }
  
  func loadFeaturedContentSection() -> Bool {
    let itemSize = FeaturedContentCollectionViewCell.defaultSize
    let interItemSpacing: CGFloat = 10
    let contentInset = UIEdgeInsets(
      top: 15, left: ThemeManager.shared.currentTheme.generalExternalMargin(),
      bottom: 10, right: ThemeManager.shared.currentTheme.generalExternalMargin())
    
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
    flowLayout.itemSize = itemSize
    flowLayout.minimumInteritemSpacing = interItemSpacing
    
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    collectionView.register(FeaturedContentCollectionViewCell.nib, forCellWithReuseIdentifier: FeaturedContentCollectionViewCell.reuseIdentifier)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = UIColor.clear
    collectionView.contentInset = contentInset
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.constrainHeight("\(itemSize.height + contentInset.top + contentInset.bottom)")
    collectionView.constrainWidth("\(self.view.frame.width)")
    
    stackView.addArrangedSubview(collectionView)
    
    return true
  }
  
  func loadViewAllCategories() -> Bool {
    let disclosureView = UIView.loadFromView(DisclosureView.self, owner: nil)
    disclosureView.style = .highlighted
    disclosureView.delegate = self
    disclosureView.label.text = viewModel.viewAllCategoriesLabelText
    
    disclosureView.constrainHeight("45")
    stackView.addArrangedSubview(disclosureView)
    disclosureView.alignLeadingEdge(withView: stackView, predicate: "0")
    disclosureView.alignTrailingEdge(withView: stackView, predicate: "0")
    return true
  }
  
  func addSeparator(_ leftMargin: CGFloat = 0) {
    let separatorView = UIView(frame: CGRect.zero)
    separatorView.backgroundColor = ThemeManager.shared.currentTheme.defaultSeparatorColor()
    separatorView.constrainHeight("1")
    stackView.addArrangedSubview(separatorView)
    separatorView.alignLeadingEdge(withView: stackView, predicate: "\(leftMargin)")
    separatorView.alignTrailingEdge(withView: stackView, predicate: "0")
  }
  
  func addSpacing(space: CGFloat) {
    guard space > 0 else {
      return
    }
    
    let spacer = UIView(frame: CGRect.zero)
    spacer.backgroundColor = UIColor.clear
    spacer.constrainHeight("\(space)")
    stackView.addArrangedSubview(spacer)
  }
}

extension BookStoreViewController: DisclosureViewDelegate {
  func disclosureViewTapped() {
    print("View ALl categories")
  }
}



extension BookStoreViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.featuredContentNumberOfItems
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedContentCollectionViewCell.reuseIdentifier, for: indexPath) as? FeaturedContentCollectionViewCell else {
      return UICollectionViewCell()
    }
    
    let data = viewModel.dataForFeaturedContent(indexPath: indexPath)
    cell.title = data.title
    cell.image = data.image
    return cell
  }
}

extension BookStoreViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO: Handle featured content selection
  }
}
