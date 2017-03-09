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
}
