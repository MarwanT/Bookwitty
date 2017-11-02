//
//  ReadingListsViewModel.swift
//  Bookwitty
//
//  Created by charles on 3/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

final class ReadingListsViewModel {
  fileprivate var dataArray: [ReadingList] = []
  fileprivate var readingListContentPaginator: Paginator!

  //Makes sure no batch for identifiers is called twice
  fileprivate var queuedIdentifiers: [String] = []

  func initialize(with lists: [ReadingList]) {
    dataArray.removeAll()
    dataArray += lists

    initializeContent()
  }

  func initializeContent() {
    let readingListIdentifiers: [String] = dataArray.flatMap({ $0.id })
    readingListContentPaginator = Paginator(ids: readingListIdentifiers)
  }

  func loadNextReadingListPageContent(closure: ((Bool, [Int]) -> ())?) {
    if let identifiers = readingListContentPaginator.currentIdentifiers() {

      //return if the identifers are already queued
      guard !Set(identifiers).isSubset(of: queuedIdentifiers) else {
        closure?(false, [])
        return
      }

      //enqueue the identifiers
      queuedIdentifiers += identifiers

      //filter only the reading lists that we're getting the content of
      let readingLists = dataArray.filter({ identifiers.contains($0.id ?? "") })

      //construct the posts identifier array to fetch the content of
      let postsIdentifiers: [String] = readingLists.reduce([], { (cumulative, current: ReadingList) -> [String] in

        //constraint the posts to a max of 10
        let constrainedIdentifiers: [String]? = current.postsRelations?.prefix(10).flatMap({ $0.id })

        //if the post already contains modeled posts skip it
        guard (current.posts?.count ?? 0) < (constrainedIdentifiers?.count ?? 0) else {
          return cumulative
        }

        //append the constrained identifiers
        return cumulative + (constrainedIdentifiers ?? [])
      })

      loadContentBatch(with: postsIdentifiers, closure: { (success: Bool, indices: [Int]) in
        if success {
          //increment the page number by 1
          self.readingListContentPaginator.incrementPage()
        } else {
          //Empty the queued identifiers to allow them to be fetched again
          identifiers.forEach({
            if let index = self.queuedIdentifiers.index(of: $0) {
              self.queuedIdentifiers.remove(at: index)
            }
          })
        }
        closure?(success, indices)
      })
    }
  }

  fileprivate func loadContentBatch(with identifiers: [String], closure: ((Bool, [Int]) -> ())?) {
    var indices: [Int] = []
    _ = UserAPI.batch(identifiers: identifiers) {
      (success: Bool, resources: [ModelResource]?, error: BookwittyAPIError?) in
      defer {
        closure?(success, Array(Set(indices)))
      }

      if success, let resources = resources {
        resources.forEach({ (resource: ModelResource) in
          let readingListsContainingResource: [ReadingList] = self.dataArray.filter({ $0.postsRelations?.contains(where: { $0.id == resource.id }) ?? false })
          readingListsContainingResource.forEach({
            if let index = $0.posts?.index(where: { $0.id == resource.id }) {
              $0.posts?[index] = resource
            } else {
              $0.posts?.append(resource)
            }
          })

          indices += readingListsContainingResource.reduce([], { (cumulative, readingList: ReadingList) -> [Int] in
            guard let index = self.dataArray.index(of: readingList) else {
              return cumulative
            }
            return cumulative + [index]
          })

          //update the reading lists in the data manager
          DataManager.shared.update(resources: readingListsContainingResource)
        })
      }
    }
  }
}

//MARK: - Collection Helpers
extension ReadingListsViewModel {
  func numberOfItems() -> Int {
    return dataArray.count
  }

  func readingList(at item: Int) -> ReadingList? {
    guard item >= 0 && item < dataArray.count else {
      return nil
    }

    return dataArray[item]
  }

  func resourceForIndex(indexPath: IndexPath) -> ReadingList? {
    guard dataArray.count > indexPath.row else { return nil }
    let resource = dataArray[indexPath.row]
    return resource
  }

  func indexPathForAffectedItems(resourcesIdentifiers: [String], visibleItemsIndexPaths: [IndexPath]) -> [IndexPath] {
    let readingLists = DataManager.shared.fetchResources(with: dataArray.flatMap({ $0.id }))
    dataArray.removeAll()
    dataArray += readingLists as? [ReadingList] ?? []

    return visibleItemsIndexPaths.filter({
      indexPath in
      guard let resource = resourceForIndex(indexPath: indexPath) as? ModelCommonProperties, let identifier = resource.id else {
        return false
      }
      return resourcesIdentifiers.contains(identifier)
    })
  }

  func deleteResource(with identifier: String) {
    if let index = dataArray.index(where: { $0.id == identifier }) {
      dataArray.remove(at: index)
    }
  }
}

// MARK: - Posts Actions
extension ReadingListsViewModel {
  func witContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let contentId = resource.id else {
        completionBlock(false)
        return
    }

    _ = NewsfeedAPI.wit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.wit)
      }
      completionBlock(success)
    })
  }

  func unwitContent(indexPath: IndexPath, completionBlock: @escaping (_ success: Bool) -> ()) {
    guard let resource = resourceForIndex(indexPath: indexPath),
      let contentId = resource.id else {
        completionBlock(false)
        return
    }

    _ = NewsfeedAPI.unwit(contentId: contentId, completion: { (success, error) in
      if success {
        DataManager.shared.updateResource(with: contentId, after: DataManager.Action.unwit)
      }
      completionBlock(success)
    })
  }

  func sharingContent(indexPath: IndexPath) -> [String]? {
    guard let resource = resourceForIndex(indexPath: indexPath) else {
        return nil
    }

    let shortDesciption = resource.title ?? resource.shortDescription ?? ""
    if let sharingUrl = resource.canonicalURL {
      return [shortDesciption, sharingUrl.absoluteString]
    }
    return [shortDesciption]
  }
}
