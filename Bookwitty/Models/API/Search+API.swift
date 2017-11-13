//
//  Search+API.swift
//  Bookwitty
//
//  Created by charles on 2/22/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import UIKit
import Moya
import Spine

struct SearchAPI {
  static func search(filter: Filter?, page: (number: String?, size: String?)?, includeFacets: Bool = false, completion: @escaping (_ success: Bool, _ collection: [ModelResource]?, _ nextPage: URL?, _ facet: Facet?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.search(filter: filter, page: page, includeFacets: includeFacets)) {
      (data, statusCode, response, error) in
      var success: Bool = false
      var collection: [ModelResource]? = nil
      var nextPage: URL? = nil
      var facet: Facet? = nil
      var error: BookwittyAPIError? = nil
      defer {
        completion(success, collection, nextPage, facet, error)
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }
      // Parse Data
      guard let parsedData = Parser.parseDataArray(data: data) else {
        error = BookwittyAPIError.failToParseData
        return
      }
      //TODO: handle parsedData.errors if any
      collection = parsedData.resources
      nextPage = parsedData.next
      if let facets = parsedData.metadata?["facets"] as? [String : Any] {
        facet = Facet(from: facets)
      }
      success = parsedData.resources != nil
      error = nil
    }
  }

  static func autocomplete(filter: Filter?, page: (number: String?, size: String?)?, includeFacets: Bool = false, completion: @escaping (_ success: Bool, _ collection: [ModelResource]?, _ nextPage: URL?, _ facet: Facet?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.autocomplete(filter: filter, page: page, includeFacets: includeFacets)) {
      (data, statusCode, response, error) in
      var success: Bool = false
      var collection: [ModelResource]? = nil
      var nextPage: URL? = nil
      var facet: Facet? = nil
      var error: BookwittyAPIError? = nil
      defer {
        completion(success, collection, nextPage, facet, error)
      }

      guard let data = data else {
        error = BookwittyAPIError.failToParseData
        return
      }
      // Parse Data
      guard let parsedData = Parser.parseDataArray(data: data) else {
        error = BookwittyAPIError.failToParseData
        return
      }
      //TODO: handle parsedData.errors if any
      collection = parsedData.resources
      nextPage = parsedData.next
      if let facets = parsedData.metadata?["facets"] as? [String : Any] {
        facet = Facet(from: facets)
      }
      success = parsedData.resources != nil
      error = nil
    }
  }
}

extension SearchAPI {
  static func parameters(filter: Filter?, page: (number: String?, size: String?)?, includeFacets: Bool) -> [String : Any]? {
    var dictionary = [String : Any]()

    //Filters
    if let filter = filter {
      if let query = filter.query {
        dictionary["filter[query]"] = query
      }

      if !filter.categories.isEmpty {
        dictionary["filter[category]"] = filter.categories
      }

      if !filter.languages.isEmpty {
        dictionary["filter[language]"] = filter.languages
      }

      if !filter.types.isEmpty {
        dictionary["filter[types]"] = filter.types
      }
    }

    //Pagination
    if let page = page {
      if let number = page.number {
        dictionary["page[number]"] = number
      }

      if let size = page.size {
        dictionary["page[size]"] = size
      }
    }

    if includeFacets {
      dictionary["filter[facets]"] = Facet.Filter.dictionary
    }
    
    return dictionary
  }
}
