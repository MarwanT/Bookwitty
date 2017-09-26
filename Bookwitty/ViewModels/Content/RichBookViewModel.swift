//
//  RichBookViewModel.swift
//  Bookwitty
//
//  Created by ibrahim on 9/26/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation
import Moya

final class RichBookViewModel {
  var data: [String] = []
  var cancellableRequest: Cancellable?
  var misfortuneNodeMode: MisfortuneNode.Mode? = nil
  var nextPage: URL?
  var filter: Filter = Filter()

  init() {
    self.filter.types = [Book.resourceType]
  }
  
  func resourceFor(id: String?) -> ModelResource? {
    guard let id = id else {
      return nil
    }
    return DataManager.shared.fetchResource(with: id)
  }
  
  func cancelActiveRequest() {
    guard let cancellableRequest = cancellableRequest else {
      return
    }
    if !cancellableRequest.isCancelled {
      cancellableRequest.cancel()
    }
  }

  func clearSearchData() {
    //Cancel any on-goin request
    cancelActiveRequest()
    self.data.removeAll(keepingCapacity: false)
  }


  func search(query: String, completion: @escaping (_ success: Bool, _ error: BookwittyAPIError?) -> Void) {
    //Cancel any on-goin request
    cancelActiveRequest()
    
    self.data.removeAll(keepingCapacity: false)
    cancellableRequest = SearchAPI.search(filter: filter, page: nil, includeFacets: false, completion: {
      (success, resources, nextPage, facet, error) in
      defer {
        // Set misfortune node mode
        if self.data.count > 0 {
          self.misfortuneNodeMode = nil
        } else {
          if let isReachable = AppManager.shared.reachability?.isReachable, !isReachable {
            self.misfortuneNodeMode = MisfortuneNode.Mode.noInternet
          } else {
            self.misfortuneNodeMode = MisfortuneNode.Mode.noResultsFound
          }
        }
        completion(success, error)
      }
      
      guard success, let resources = resources else {
        return
      }
      
      DataManager.shared.update(resources: resources)
      self.data += resources.flatMap({ $0.id })
      self.nextPage = nextPage
    })
  }
  func loadNextPage(completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let nextPage = nextPage else {
      completionBlock(false)
      return
    }
    //Cancel any on-goin request
    cancelActiveRequest()
    
    cancellableRequest = GeneralAPI.nextPage(nextPage: nextPage) { (success, resources, nextPage, error) in
      if let resources = resources, success {
        DataManager.shared.update(resources: resources)
        
        self.data += resources.flatMap({ $0.id })
        self.nextPage = nextPage
      }
      self.cancellableRequest = nil
      completionBlock(success)
    }
  }
  
  func hasNextPage() -> Bool {
    return (self.nextPage != nil)
  }
  
  func indexPathForAffectedItems(resourcesIdentifiers: [String], visibleItemsIndexPaths: [IndexPath]) -> [IndexPath] {
    return visibleItemsIndexPaths.filter({
      indexPath in
      guard let resource = resourceForIndex(indexPath: indexPath) as? ModelCommonProperties, let identifier = resource.id else {
        return false
      }
      return resourcesIdentifiers.contains(identifier)
    })
  }
}

// Mark: - Collection helper
extension RichBookViewModel {
  func numberOfSections() -> Int {
    return RichBookViewController.Section.numberOfSections
  }
  
  func numberOfItemsInSection(section: Int) -> Int {
    return RichBookViewController.Section.activityIndicator.rawValue == section ? 1 : data.count
  }
  
  func resourceForIndex(indexPath: IndexPath) -> ModelResource? {
    guard data.count > indexPath.row else { return nil }
    let resourceId = data[indexPath.row]
    return resourceFor(id: resourceId)
  }
}
