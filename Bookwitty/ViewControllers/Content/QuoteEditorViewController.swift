//
//  QuoteEditorViewController.swift
//  Bookwitty
//
//  Created by Charles Abou Yakzan on 2017/09/26.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class QuoteEditorViewController: UIViewController {

  @IBOutlet var quoteTextView: UITextView!
  @IBOutlet var authorTextView: UITextView!
  @IBOutlet var separators: [UIView]!

  fileprivate let viewModel = QuoteEditorViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
  }

  fileprivate func initializeComponents() {
    title = Strings.quote()
  }
}
