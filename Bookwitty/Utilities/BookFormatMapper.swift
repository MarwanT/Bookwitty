//
//  BookFormatMapper.swift
//  Bookwitty
//
//  Created by Marwan  on 6/23/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class BookFormatMapper {
  var formats: [ProductForm]? = nil
  
  static let shared: BookFormatMapper = BookFormatMapper()
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
    return dictionary.flatMap({ ProductForm(key: $0.key, value: ($0.value as? String) ?? "") })
  }
  
  // MARK: Manager APIs
  func formatString(for key: String) -> String {
    let lowerCaseKey = key.lowercased()
    return formats?.filter({ $0.key.lowercased() == lowerCaseKey }).first?.value ?? ""
  }
  
  func productForm(for key: String) -> ProductForm? {
    let lowerCaseKey = key.lowercased()
    return formats?.filter({ $0.key.lowercased() == lowerCaseKey }).first
  }
  
  /// Returns an array of the available given format keys
  func validKeys(from listOfKeys: [String]) -> [String] {
    var keys = [String]()
    
    if let availableKeys = formats?.flatMap({ $0.key.lowercased() }) {
      keys = listOfKeys.flatMap({ availableKeys.contains($0.lowercased()) ? $0 : nil })
    }
    
    return keys
  }
}

//MARK: - Localizable implementation
extension BookFormatMapper: Localizable {
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
