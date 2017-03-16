//
//  ForgotPasswordViewController.swift
//  Bookwitty
//
//  Created by charles on 3/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

  @IBOutlet weak var emailField: InputField!
  @IBOutlet weak var submitButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    initializeComponents()
  }

  private func initializeComponents() {

  }
}
