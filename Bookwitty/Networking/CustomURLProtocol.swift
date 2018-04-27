//
//  CustomURLProtocol.swift
//  webview-redirections
//
//  Created by charles on 5/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

class CustomURLProtocol: URLProtocol {

  struct Constants {
    static let RequestHandledKey = "URLProtocolRequestHandled"
  }

  var session: URLSession?
  var sessionTask: URLSessionDataTask?

  override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
    super.init(request: request, cachedResponse: cachedResponse, client: client)

    if session == nil {
      session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
  }

  override class func canInit(with request: URLRequest) -> Bool {
    let isFacebookLoginCallback: Bool = request.url?.absoluteString.contains(Environment.current.facebookLoginCallbackPath) ?? false
    if isFacebookLoginCallback {
      return true
    }

    if CustomURLProtocol.property(forKey: Constants.RequestHandledKey, in: request) != nil {
      return false
    }
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    var jsonRequest = request
    let isFacebookLoginCallback: Bool = request.url?.absoluteString.contains(Environment.current.facebookLoginCallbackPath) ?? false
    if isFacebookLoginCallback {
      var dictionary = jsonRequest.allHTTPHeaderFields ?? [:]
      let token = AccessToken.shared.token ?? ""
      dictionary.updateValue("application/json", forKey: "Accept")
      dictionary.updateValue("application/json", forKey: "Content-Type")
      dictionary.updateValue("Bearer \(token)", forKey: "Authorization")
      jsonRequest.allHTTPHeaderFields = dictionary
    }
    return jsonRequest
  }

  override func startLoading() {
    let newRequest = ((request as NSURLRequest).mutableCopy() as? NSMutableURLRequest)!
    CustomURLProtocol.setProperty(true, forKey: Constants.RequestHandledKey, in: newRequest)
    sessionTask = session?.dataTask(with: newRequest as URLRequest)
    sessionTask?.resume()
  }

  override func stopLoading() {
    sessionTask?.cancel()
  }
}

extension CustomURLProtocol: URLSessionDataDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    client?.urlProtocol(self, didLoad: data)
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
    let policy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: policy)
    completionHandler(.allow)
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error = error {
      client?.urlProtocol(self, didFailWithError: error)
    } else {
      client?.urlProtocolDidFinishLoading(self)
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
    client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    completionHandler(request)
  }

  func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
    guard let error = error else { return }
    client?.urlProtocol(self, didFailWithError: error)
  }

  func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    let protectionSpace = challenge.protectionSpace
    let sender = challenge.sender

    if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
      if let serverTrust = protectionSpace.serverTrust {
        let credential = URLCredential(trust: serverTrust)
        sender?.use(credential, for: challenge)
        completionHandler(.useCredential, credential)
        return
      }
    }
  }

  func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
    client?.urlProtocolDidFinishLoading(self)
  }
}
