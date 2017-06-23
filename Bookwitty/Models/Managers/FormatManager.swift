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
    loadFormatsFromJSON()
  }
  
  fileprivate func loadFormatsFromJSON() {
    let language = GeneralSettings.sharedInstance.preferredLanguage
    
    guard let url = Bundle.main.url(forResource: "Formats." + language, withExtension: "json") else {
      print("Fail to get formats file path")
      return
    }
    
    guard let data = try? Data(contentsOf: url),
      let dictionary = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
        print("Fail to load dictionary from formats file")
        return
    }
    
    guard let formatsDictionary = dictionary?[language] as? [String : Any] else {
      print("Fail to load localized formats")
      return
    }
    
    formats = formatsFromDictionary(dictionary: formatsDictionary)
  }
  
  func formatsFromDictionary(dictionary: [String : Any]) -> [ProductForm] {
    return dictionary.flatMap({ $0 as? ProductForm })
  }
  
  // MARK: Manager APIs
  func formatString(for key: String) -> String {
    let lowerCaseKey = key.lowercased()
    return formats?.filter({ $0.key.lowercased() == lowerCaseKey }).first?.value ?? ""
  }
}

//MARK: - Localizable implementation
extension FormatManager: Localizable {
  func applyLocalization() {
    loadFormatsFromJSON()
  }
  
  fileprivate func observeLanguageChanges() {
    NotificationCenter.default.addObserver(self, selector: #selector(languageValueChanged(notification:)), name: Localization.Notifications.Name.languageValueChanged, object: nil)
  }
  
  @objc
  fileprivate func languageValueChanged(notification: Notification) {
    applyLocalization()
  }
}
