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
    collectionView.backgroundColor = UIColor.orange
    collectionView.contentInset = contentInset
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.constrainHeight("\(itemSize.height + contentInset.top + contentInset.bottom)")
    collectionView.constrainWidth("\(self.view.frame.width)")
    
    stackView.addArrangedSubview(collectionView)
    
    return true
  }
}
