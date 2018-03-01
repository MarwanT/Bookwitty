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
  case maxTagsAllowed
  case invalidStatusCode
  case failToRetrieveDictionary
  case failToParseData
  case failToSignIn
  case invalidCurrentPassword
  case penNameHasAlreadyBeenTaken
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
    case .uploadMultipart:
      break
    case .register:
      let accessToken = AccessToken.shared
      if let token = accessToken.token, accessToken.isValid {
        headerParameters["Authorization"] = "Bearer \(token)"
      }
      fallthrough
    case .oAuth, .refreshToken:
      headerParameters["Content-Type"] = "application/json"
      headerParameters["Accept"] = "application/json"
    default:
      let accessToken = AccessToken.shared
      if let token = accessToken.token, accessToken.isValid {
        headerParameters["Authorization"] = "Bearer \(token)"
        if let penName = UserManager.shared.defaultPenName,
           let id = penName.id {
          headerParameters["X-Bookwitty-Pen-Name"] = id
        }
      }
      headerParameters["Content-Type"] = "application/vnd.api+json"
      headerParameters["Accept"] = "application/vnd.api+json"

      if let language = Localization.Language(rawValue: GeneralSettings.sharedInstance.preferredLanguage) {
        headerParameters["Accept-Language"] = language.rawValue
      }
    }

    headerParameters["User-Agent"] = userAgentValue

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

    if let includes = target.includes {
      let includeTypes = includes.map({ $0 }).joined(separator: ",")
      endpoint = endpoint.adding(newParameters: ["include" : includeTypes])
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

extension APIProvider {
  static var userAgentValue: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    let currentDevice = UIDevice.current
    let deviceType = currentDevice.deviceType
    return "Bookwitty/\(version)+\(buildNumber) (iOS/\(currentDevice.systemVersion); \(deviceType.displayName);)"
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
  return {
    return apiRequest(target: target, completion: completion)
  }
}

public func apiRequest(target: BookwittyAPI, completion: @escaping BookwittyAPICompletion) -> Cancellable {
  showActivityIndicator()
  return APIProvider.sharedProvider.request(target, completion: { (result) in
    hideActivityIndicator()
    switch result {
    case .success(let response):
      // If account need confirmation send notification
      if response.statusCode == 403, ErrorManager.shared.dataContainsAccountNeedsConfirmationError(data: response.data).hasError {
        NotificationCenter.default.post(
          name: AppNotification.accountNeedsConfirmation, object: nil)
      } else if response.statusCode == 429 {
        NotificationCenter.default.post(
          name: AppNotification.tooManyRequests, object: nil)
      } else if response.statusCode == 503 {
        NotificationCenter.default.post(
          name: AppNotification.serverIsBusy, object: nil)
      }
      completion(response.data, response.statusCode, response.response, nil)
    case .failure(let error):
      completion(nil, nil, nil, BookwittyAPIError(moyaError: error))
    }
  })
}

/*
 *  TODO: Rename this method to apiRequest and refactor the above.
 */
public func signedAPIRequest(target: BookwittyAPI, completion: @escaping BookwittyAPICompletion) -> Cancellable? {
  let apiRequest = createAPIRequest(target: target, completion: completion)
  
  let accessToken = AccessToken.shared
  let appManager = AppManager.shared
  
  if (accessToken.isUpdating || appManager.isCheckingStatus) {
    operationQueue.append((target: target, completion: completion))
    return nil
  }
  
  guard case AppDelegate.Status.valid = appManager.appStatus else {
    if case AppDelegate.Status.unspecified = appManager.appStatus {
      appManager.checkAppStatus()
    }
    operationQueue.append((target: target, completion: completion))
    return nil
  }
  
  if !accessToken.isValid {
    return fetchValidToken(completion: { (success) in
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

public func fetchValidToken(completion: @escaping (_ success: Bool) -> Void) -> Cancellable? {
  if UserManager.shared.isSignedIn {
    return refreshAccessToken(completion: completion)
  } else {
    return fetchGuestToken(completion: completion)
  }
}

public func refreshAccessToken(completion: @escaping (_ success:Bool) -> Void) -> Cancellable? {
  let accessToken = AccessToken.shared
  
  guard let refreshToken = accessToken.refreshToken else {
    NotificationCenter.default.post(name: AppNotification.failToRefreshToken, object: nil)
    completion(false)
    return nil
  }
  
  accessToken.updating = true
  
  return APIProvider.sharedProvider.request(
    .refreshToken(refreshToken: refreshToken),
    completion: { (result) in
    var success = false
    defer {
      accessToken.updating = false
      completion(success)
    }
    
    switch result {
    case .success(let response):
      if response.statusCode == 400 || response.statusCode == 401 {
        NotificationCenter.default.post(name: AppNotification.failToRefreshToken, object: nil)
        return
      }
      
      do {
        guard let accessTokenDictionary = try JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary else {
          return
        }
        accessToken.save(dictionary: accessTokenDictionary)
        success = true
      } catch {
        print("Error casting token data as dictionary")
      }
    case .failure(let error):
      print("Error Refreshing token: \(error)")
    }
  })
}

public func fetchGuestToken(completion:@escaping (_ success:Bool) -> Void) -> Cancellable? {
  let accessToken = AccessToken.shared
  
  accessToken.updating = true
  
  return apiRequest(
  target: BookwittyAPI.oAuth(credentials: nil)) {
    (data, statusCode, response, error) in
    // Ensure the completion block is always called
    var success: Bool = false
    defer {
      accessToken.updating = false
      completion(success)
    }
    
    // If status code is not available then break
    guard let statusCode = statusCode, statusCode == 200 else {
      return
    }
    
    // Retrieve Dictionary from data
    do {
      guard let data = data, let dictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary else {
        return
      }
      // Save token
      AccessToken.shared.save(dictionary: dictionary)
      success = true
    } catch {}
  }
}

func executePendingOperations(success: Bool) {
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

// MARK: - Activity Indicator
func showActivityIndicator() {
  DispatchQueue.main.async {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }
}

func hideActivityIndicator() {
  DispatchQueue.main.async {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}
