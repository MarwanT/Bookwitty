//
//  FormatManager.swift
//  Bookwitty
//
//  Created by Marwan  on 6/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

typealias ProductForm = Dictionary<String, String>.Element

class FormatManager {
  var formats: [ProductForm]? = nil
  
  static let shared: FormatManager = FormatManager()
  private init() {
    observeLanguageChanges()
  }
}

//MARK: - Localizable implementation
extension FormatManager: Localizable {
  func applyLocalization() {
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
