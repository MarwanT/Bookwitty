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
  case AllAddresses
}

// MARK: - Target Type

extension TargetType {
  var headerParameters: [String:String]? {
    return nil
  }
}

extension BookwittyAPI: TargetType {
  public var baseURL: URL {
    return Environment.current.baseURL
  }
  
  public var path: String {
    let apiVersion = "/v1"
    var path = ""
    
    switch self {
    case .AllAddresses:
      path = "/user/addresses"
    }
    
    return apiVersion + path
  }
  
  public var method: Moya.Method {
    switch self {
    case .AllAddresses:
      return .get
    }
  }
  
  public var parameters: [String: Any]? {
    switch self {
    case .AllAddresses:
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
