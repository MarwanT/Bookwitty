//
//  Parser.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

protocol Parsable {
  associatedtype AbstractType: Resource
  static func parseData(data: Data?) -> AbstractType?
  static func parseDataArray(data: Data?) -> Array<AbstractType>?
  func serializeData(options: SerializationOptions) -> [String : Any]?
}

extension Parsable where Self: Resource {
  //Mark: - Default Parsing Implementation
  static func parseData(data: Data?) -> AbstractType? {
    guard let data = data else {
      return nil
    }

    let serializer = Parser.sharedInstance.serializer
    
    do {
      let document = try serializer.deserializeData(data)
      if let parsableModel = document.data?.first as? AbstractType {
        return parsableModel
      } else {
        print("Could not parse data to \(self) model")
      }
    } catch let error as NSError {
      print("Error parsing \(self) model")
      print(error)
    }
    return nil
  }

  static func parseDataArray(data: Data?) -> Array<AbstractType>? {
    return nil
  }

  func serializeData(options: SerializationOptions) -> [String : Any]? {
      let serializer = Parser.sharedInstance.serializer
    do {
      let data = try serializer.serializeResources([self], options: options)
      let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
      return dictionary
    } catch let error as NSError {
      print("Error serializng \(self) model")
      print(error)
    }
    return [:]
  }
}

class Parser {
  static let sharedInstance = Parser()
  let serializer: Serializer = Serializer()

  init() {
    serializer.keyFormatter = DasherizedKeyFormatter()
    registerResources()
    registerValueFormatters()
  }

  private func registerResources() {
    serializer.registerResource(User.self)
    serializer.registerResource(PenName.self)
    serializer.registerResource(Image.self)
    serializer.registerResource(Author.self)
    serializer.registerResource(PageAuthor.self)
    serializer.registerResource(ReadingList.self)
    serializer.registerResource(Topic.self)
  }

  private func registerValueFormatters() {
    //Register any value formatter here using the serializer
  }
}
