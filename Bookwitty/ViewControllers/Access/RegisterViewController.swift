//
//  RegisterViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 1/31/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
  let viewModel: RegisterViewModel = RegisterViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    awakeSelf()
  }

  /// Do the required setup
  private func awakeSelf() {
    title = viewModel.viewControllerTitle
  }
}
