//
//  Networking.swift
//  Bookwitty
//
//  Created by Marwan  on 1/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

public typealias BookwittyAPIError = MoyaError

/**
 An endpoint is a semi-internal data structure that Moya uses to reason about the network request that will ultimately be made. An endpoint stores the following data: 
 * The url.
 * The HTTP method (GET, POST, etc).
 * The request parameters.
 * The parameter encoding (URL, JSON, custom, etc).
 * The HTTP request header fields.
 * The sample response (for unit testing).
 
 
 *Providers map Targets to Endpoints, then map Endpoints to actual network requests.*
 
 **There are two ways that you interact with Endpoints:**
 * When creating a provider, you may specify a mapping from **Target** to **Endpoint**.
 * When creating a provider, you may specify a mapping from **Endpoint** to **URLRequest**.
 */

public struct APIProvider {
  //-----------------------------------------
  /// mapping from **Target** to **Endpoint**
  private static var endpointClosure = { (target: BookwittyAPI) -> Endpoint<BookwittyAPI> in
    // Create Endpoint
    var endpoint: Endpoint<BookwittyAPI> = Endpoint<BookwittyAPI>(
      url: absoluteString(for: target),
      sampleResponseClosure:{ () -> EndpointSampleResponse in
        return .networkResponse(200, target.sampleData)
      },
      method: target.method,
      parameters: target.parameters,
      parameterEncoding: target.parameterEncoding,
      httpHeaderFields: nil)
    
    // Add Header Fields to Endpoint
    var headerParameters = [String : String]()
    switch target{
    default:
      headerParameters["Authorization"] = "Bearer token_value"
      break
    }
    headerParameters["Content-Type"] = "application/vnd.api+json"
    
    if headerParameters.count > 0 {
      endpoint = endpoint.adding(newHTTPHeaderFields: headerParameters)
    }

    // return Endpoint
    return endpoint
  }
  
  //---------------------------------------------
  /// mapping from **Endpoint** to **URLRequest**
  private static var requestClosure = { (endpoint: Endpoint<BookwittyAPI>, done: MoyaProvider.RequestResultClosure) in
    var request = endpoint.urlRequest!
    request.httpShouldHandleCookies = false
    done(.success(request))
  }
  
  
  private struct SharedProvider {
    static var instance = SharedProvider.shouldStubResponses ? APIProvider.StubbedProvider() : APIProvider.DefaultProvider()
    
    private static var shouldStubResponses: Bool {
      let env = ProcessInfo.processInfo.environment
      if let mode = env["STUB_RESPONSES"]?.lowercased() {
        return (mode == "yes")||(mode == "true")
      }
      return false
    }
  }
  
  private static func DefaultProvider() -> MoyaProvider<BookwittyAPI> {
    return MoyaProvider<BookwittyAPI>(
      endpointClosure: endpointClosure,
      requestClosure: requestClosure,
      stubClosure:{ (target: BookwittyAPI) -> Moya.StubBehavior in
        return .never
      }
    )
  }
  
  private static func StubbedProvider() -> MoyaProvider<BookwittyAPI> {
    return MoyaProvider<BookwittyAPI>(
      endpointClosure: endpointClosure,
      requestClosure:requestClosure,
      stubClosure: { (target: BookwittyAPI) -> StubBehavior in
        return StubBehavior.delayed(seconds: 3)
    }
    )
  }
  

  public static var sharedProvider: MoyaProvider<BookwittyAPI> {
    get {
      return SharedProvider.instance
    }
    
    set (newSharedProvider) {
      SharedProvider.instance = newSharedProvider
    }
  }
}

public func absoluteString(for target: TargetType) -> String {
  guard !target.path.isEmpty else {
    return target.baseURL.absoluteString
  }
  return  target.baseURL.appendingPathComponent(target.path).absoluteString
}
