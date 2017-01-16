//
//  BookwittyAPI.swift
//  Bookwitty
//
//  Created by Marwan  on 1/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya


// MARK: - Enum Declaration

public enum BookwittyAPI {

}

// MARK: Target Type

extension BookwittyAPI: TargetType {
  public var baseURL: URL {
    return URL(string: "https://private-7bb9fa-dannyhajj.apiary-mock.com/api")!
  }
  
  public var path: String {
    let apiVersion = "/v1"
    var path = ""
    
    switch self {
    default:
      return apiVersion + path
    }
  }
  
  public var method: Moya.Method {
    switch self {
    default:
      return .get
    }
  }
  
  public var parameters: [String: Any]? {
    switch self {
    default:
      return nil
    }
  }
  
  public var parameterEncoding: ParameterEncoding {
    switch self.method {
    case .get:
      return URLEncoding.default
    default:
      return JSONEncoding.default
    }
  }
  
  public var sampleData: Data {
    return stubbedResponse(target: self)
  }
  
  /// The type of HTTP task to be performed.
  public var task: Task {
    switch self {
    default:
      return .request
    }
  }
  
  /// Whether or not to perform Alamofire validation. Defaults to `false`.
  public var validate: Bool {
    return false
  }
}

// MARK: - Global Helpers

func stubbedResponse(target: BookwittyAPI) -> Data! {
  var filename: String = ""
  
  switch target {
  default:
    filename = ""
  }
  
  let bundle = Bundle.main
  let path = "\(bundle.resourcePath!)/\(filename).json"
  return (try? Data(contentsOf: URL(fileURLWithPath: path)))
}
