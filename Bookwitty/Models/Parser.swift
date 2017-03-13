//
//  Parser.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/5/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Spine

typealias ModelResource = Resource

protocol Parsable {
  associatedtype AbstractType: Resource
  static func parseData(data: Data?) -> AbstractType?
  static func parseDataArray(data: Data?) -> (resources: Array<AbstractType>?, next: URL?, errors: [APIError]?)?
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

  static func parseDataArray(data: Data?) -> (resources: [AbstractType]?, next: URL?, errors: [APIError]?)? {
    guard let data = data,
      let values = Parser.parseDataArray(data: data) else {
      return nil
    }

    let resources: [AbstractType]? = values.resources?.flatMap({ $0 as? AbstractType })
    let next: URL? = values.next
    let error: [APIError]? = values.errors

    return (resources, next, error)
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
    serializer.registerResource(Text.self)
    serializer.registerResource(Quote.self)
    serializer.registerResource(Video.self)
    serializer.registerResource(Audio.self)
    serializer.registerResource(Link.self)
    serializer.registerResource(CuratedCollection.self)
    serializer.registerResource(Book.self)
  }

  private func registerValueFormatters() {
    //Register any value formatter here using the serializer
    serializer.registerValueFormatter(CuratedCollectionSectionsValueFormatter())
    serializer.registerValueFormatter(ProductDetailsValueFormatter())
    serializer.registerValueFormatter(SupplierInformationValueFormatter())
  }

  static func parseData(data: Data?, mappingTargets: [Resource]? = nil) -> JSONAPIDocument? {
    guard let data = data else {
      return nil
    }

    let serializer = Parser.sharedInstance.serializer
    do {
      let document = try serializer.deserializeData(data, mappingTargets: mappingTargets, options: [.SkipUnregisteredType])
      return document
    } catch let error as NSError {
      print("Error parsing data")
      print(data)
      print(error)
    }
    return nil
  }

  static func parseDataArray(data: Data?, mappingTargets: [Resource]? = nil) -> (resources: [Resource]?, next: URL?, errors: [APIError]?)? {
    guard let data = data else {
      return nil
    }
    guard let document: JSONAPIDocument = parseData(data: data, mappingTargets: mappingTargets) else {
      print("Error parsing Array of models")
      return nil
    }

    let next = document.links?["next"]
    
    if let parsedData = document.data {
      return (parsedData, next, document.errors)
    }

    return (nil, next, document.errors)
  }
}

extension Resource {
  final var registeredResourceType: ResourceType {
    return type(of: self).resourceType
  }
}
