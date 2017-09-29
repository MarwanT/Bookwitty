//
//  IFramely.swift
//  iframely
//
//  Created by charles on 3/15/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

public class IFramely {
  public typealias IFramelyResponse = (_ success: Bool, _ response: Response?) -> ()

  fileprivate let baseURL: URL = URL(string: "http://iframe.ly")!
  fileprivate let endpoint: String = "/api/iframely"

  fileprivate var apiKey: String? = nil

  static let shared: IFramely = IFramely()
  private init() {}

  func initializeWith(apiKey: String) {
    self.apiKey = apiKey
  }

  public func loadResponseFor(url: URL, closure: IFramelyResponse?) {
    guard let apiKey = apiKey else {
      assertionFailure("[IFramely] - `apiKey` can't be nil")
      return
    }
    assert(apiKey.characters.count != 0, "`apiKey` can't be empty")

    let urlString = self.endpoint + "?api_key=" + apiKey + "&url=" + url.absoluteString
    guard let requestURL = URL(string: urlString, relativeTo: baseURL) else {
      assertionFailure("[IFramely] - Something went wrong, malformed url")
      return
    }

    URLSession.shared.dataTask(with: requestURL) {
      (data: Data?, response: URLResponse?, error: Error?) in
      var success: Bool = error == nil
      var value: Response? = nil
      defer {
        closure?(success, value)
      }

      value = Response(data: data)
    }.resume()
  }
}
