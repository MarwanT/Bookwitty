//
//  Networking.swift
//  Bookwitty
//
//  Created by Marwan  on 1/16/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya


public enum BookwittyAPIError: Swift.Error {
  case imageMapping(MoyaError)
  case jsonMapping(MoyaError)
  case stringMapping(MoyaError)
  case statusCode(MoyaError)
  case underlying(MoyaError)
  case requestMapping(MoyaError)
  case refreshToken
  case emailAlreadyExists
  case invalidStatusCode
  case failToRetrieveDictionary
  case failToParseData
  case undefined
  
  init(moyaError: MoyaError) {
    switch moyaError {
    case .imageMapping:
      self = .imageMapping(moyaError)
    case .jsonMapping:
      self = .jsonMapping(moyaError)
    case .requestMapping:
      self = .requestMapping(moyaError)
    case .statusCode:
      self = .statusCode(moyaError)
    case .stringMapping:
      self = .stringMapping(moyaError)
    case .underlying:
      self = .underlying(moyaError)
    }
  }
}

public typealias BookwittyAPICompletion = (_ data: Data?,_ statusCode: Int?,_ response: URLResponse?,_ error: BookwittyAPIError?) -> ()



private typealias APIOperation = (target: BookwittyAPI, completion: BookwittyAPICompletion)
private var operationQueue: [APIOperation] = [APIOperation]()


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
  private static func endpointClosure(target: BookwittyAPI) -> Endpoint<BookwittyAPI> {
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
    var headerParameters = [String : String]();
    switch target{
    case .oAuth, .register:
      headerParameters["Content-Type"] = "application/json";
      headerParameters["Accept"] = "application/json"
    default:
      let token = AccessToken()
      if token.isValid {
        headerParameters["Authorization"] = "Bearer \(token.token!)"
      }
      headerParameters["Content-Type"] = "application/vnd.api+json";
      headerParameters["Accept"] = "application/vnd.api+json"
      break
    }
    
    // Add required header fields for target
    if let targetHeaders = target.headerParameters {
      for (key, value) in targetHeaders {
        headerParameters[key] = value
      }
    }
    
    // Add header fields to Endpoint
    if headerParameters.count > 0 {
      endpoint = endpoint.adding(newHTTPHeaderFields: headerParameters)
    }

    // return Endpoint
    return endpoint
  }
  
  //---------------------------------------------
  /// mapping from **Endpoint** to **URLRequest**
  private static func requestClosure(endpoint: Endpoint<BookwittyAPI>, done: MoyaProvider<BookwittyAPI>.RequestResultClosure) {
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

// MARK: - Request API

public func createAPIRequest(target: BookwittyAPI, completion: @escaping BookwittyAPICompletion) -> (() -> Cancellable) {
  return { return apiRequest(target: target, completion: completion) }
}

public func apiRequest(target: BookwittyAPI, completion: @escaping BookwittyAPICompletion) -> Cancellable {
  return APIProvider.sharedProvider.request(target, completion: { (result) in
    switch result {
    case .success(let response):
      completion(response.data, response.statusCode, response.response, nil)
    case .failure(let error):
      completion(nil, nil, nil, BookwittyAPIError(moyaError: error))
    }
  })
}

public func signedAPIRequest(target: BookwittyAPI, completion: @escaping BookwittyAPICompletion) -> Cancellable? {
  let apiRequest = createAPIRequest(target: target, completion: completion)
  
  let accessToken = AccessToken()
  
  if (accessToken.updating) {
    operationQueue.append((target: target, completion: completion))
    return nil
  }
  
  if !accessToken.isValid {
    return refreshAccessToken(completion: { (success) in
      if success {
        _ = apiRequest()
      } else {
        completion(nil, 500, nil, BookwittyAPIError.refreshToken)
      }
      
      executePendingOperations(success: success)
    })
  }
  
  return apiRequest()
}

public func refreshAccessToken(completion: @escaping (_ success:Bool) -> Void) -> Cancellable? {
  var accessToken = AccessToken()
  accessToken.isUpdating = true
  
  guard accessToken.refresh != nil else {
    NotificationCenter.default.post(name: AppNotification.Name.failToRefreshToken, object: nil)
    completion(false)
    return nil
  }
  
  return APIProvider.sharedProvider.request(.refreshToken, completion: { (result) in
    var success = false
    defer {
      completion(success)
    }
    
    switch result {
    case .success(let response):
      accessToken.isUpdating = false
      
      if response.statusCode == 400 {
        NotificationCenter.default.post(name: AppNotification.Name.failToRefreshToken, object: nil)
        return
      }
      
      do {
        guard let accessTokenDictionary = try JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary else {
          return
        }
        accessToken.readFromDictionary(dictionary: accessTokenDictionary)
        success = true
      } catch {
        print("Error casting token data as dictionary")
      }
    case .failure(let error):
      print("Error Refreshing token: \(error)")
    }
  })
}

private func executePendingOperations(success: Bool) {
  let opQueue = operationQueue
  operationQueue.removeAll(keepingCapacity: false)
  if success {
    for op in opQueue {
      _ = signedAPIRequest(target: op.target, completion: op.completion)
    }
  } else {
    for op in opQueue {
      op.completion(nil, 500, nil, BookwittyAPIError.refreshToken)
    }
  }
}
