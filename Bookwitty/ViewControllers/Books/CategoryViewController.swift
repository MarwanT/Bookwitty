//
//  CategoryViewController.swift
//  Bookwitty
//
//  Created by Marwan  on 2/27/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  
  let viewModel = CategoryViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
