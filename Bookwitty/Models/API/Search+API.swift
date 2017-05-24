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
  static func search(filter: (query: String?, category: [String]?)?, page: (number: String?, size: String?)?, includeFacets: Bool = false, completion: @escaping (_ success: Bool, _ collection: [ModelResource]?, _ nextPage: URL?, _ error: BookwittyAPIError?) -> Void) -> Cancellable? {
    return signedAPIRequest(target: BookwittyAPI.search(filter: filter, page: page, includeFacets: includeFacets)) {
      (data, statusCode, response, error) in
      var success: Bool = false
      var collection: [ModelResource]? = nil
      var nextPage: URL? = nil
      var error: BookwittyAPIError? = nil
      defer {
        completion(success, collection, nextPage, error)
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
      success = parsedData.resources != nil
      error = nil
    }
  }
}

extension SearchAPI {
  static func parameters(filter: (query: String?, category: [String]?)?, page: (number: String?, size: String?)?, includeFacets: Bool) -> [String : Any]? {
    var dictionary = [String : Any]()

    //Filters
    if let filter = filter {
      if let query = filter.query {
        dictionary["filter[query]"] = query
      }

      if let category = filter.category {
        dictionary["filter[category]"] = category
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
