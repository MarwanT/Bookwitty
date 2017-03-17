//
//  Analytics+Constants.swift
//  Bookwitty
//
//  Created by Marwan on 1/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension Analytics {
  struct Event {
    let category: Category
    let action: Action
    let name: String
    let value: Double
  }
  
  enum Category {
    case Account
    case Quote
    case Image
    case Audio
    case Video
    case Link
    case ReadingList
    case Text
    case Topic
    case Author
    case TopicBook
    case BookProduct
    case PenName
    case NewsFeed
    case Discover
    case Search
    case BookStorefront
    case BookCategory
    case CategoriesList
    case Bag

    var name: String {
      switch self {
      case .Account:
        return "Account"
      case .Quote:
        return "Quote"
      case .Image:
        return "Image"
      case .Audio:
        return "Audio"
      case .Video:
        return "Video"
      case .Link:
        return "Link"
      case .ReadingList:
        return "Reading List"
      case .Text:
        return "Text"
      case .Topic:
        return "Topic"
      case .Author:
        return "Author"
      case .TopicBook:
        return "Topic Book"
      case .BookProduct:
        return "Book Product"
      case .PenName:
        return "Pen Name"
      case .NewsFeed:
        return "News Feed"
      case .Discover:
        return "Discover"
      case .Search:
        return "Search"
      case .BookStorefront:
        return "Book Storefront"
      case .BookCategory:
        return "Book Category"
      case .CategoriesList:
        return "Categories List"
      case .Bag:
        return "Bag"
      }
    }
  }
  
  enum Action {
    case SignIn
    case ResetPassword
    case Register
    case EditPenName
    case SwitchEmailNotification
    case ChangePassword
    case SignOut
    //
    case Wit
    case Dim
    case WitComment
    case DimComment
    //
    case Comment
    case ReplyToComment
    //
    case Share
    //
    case SelectPenNameFeed
    //
    case GoToCategory
    case GoToDetails
    case GoToPenName
    case GoToComments
    case GoToLatest
    case GoToRelatedBooks
    case GoToEditions
    case GoToFollowers
    case GoToFollowings
    case GoToRelatedCategories
    case GoToBagOnWebsite
    //
    case ViewBanner
    //
    case ViewAllTopics
    case ViewAllReadingLists
    case ViewAllReadingListContent
    case ViewAllRelatedBooks
    case ViewAllRelatedPosts
    case ViewAllComments
    case ViewAllCategories
    case ViewAllBooks
    //
    case FollowTopic
    case FollowBook
    case FollowAuthor
    case FollowPenName
    //
    case BuyThisBook
    //
    case PullToRefresh
    case LoadMore

    var name: String {
      switch self {
      case .SignIn:
        return "Sign In"
      case .ResetPassword:
        return "Reset Password"
      case .Register:
        return "Register"
      case .EditPenName:
        return "Edit Pen Name"
      case .SwitchEmailNotification:
        return "Switch Email Notification"
      case .ChangePassword:
        return "Change Password"
      case .SignOut:
        return "Sign Out"
      case .Wit:
        return "Wit"
      case .Dim:
        return "Dim"
      case .WitComment:
        return "Wit Comment"
      case .DimComment:
        return "Dim Comment"
      case .Comment:
        return "Comment"
      case .ReplyToComment:
        return "Reply To Comment"
      case .Share:
        return "Share"
      case .SelectPenNameFeed:
        return "Select Pen Name Feed"
      case .GoToCategory:
        return "Go To Category"
      case .GoToDetails:
        return "Go To Details"
      case .GoToPenName:
        return "Go To Pen Name"
      case .GoToComments:
        return "Go To Comments"
      case .GoToLatest:
        return "Go To Latest"
      case .GoToRelatedBooks:
        return "Go To Related Books"
      case .GoToEditions:
        return "Go To Editions"
      case .GoToFollowers:
        return "Go To Followers"
      case .GoToFollowings:
        return "Go To Followings"
      case .GoToRelatedCategories:
        return "Go To Related Categories"
      case .GoToBagOnWebsite:
        return "Go To Bag On Website"
      case .ViewBanner:
        return "View Banner"
      case .ViewAllTopics:
        return "View All Topics"
      case .ViewAllReadingLists:
        return "View All Reading Lists"
      case .ViewAllReadingListContent:
        return "View All Reading List Content"
      case .ViewAllRelatedBooks:
        return "View All Related Books"
      case .ViewAllRelatedPosts:
        return "View All Related Posts"
      case .ViewAllComments:
        return "View All Comments"
      case .ViewAllCategories:
        return "View All Categories"
      case .ViewAllBooks:
        return "View All Books"
      case .FollowTopic:
        return "Follow Topic"
      case .FollowBook:
        return "Follow Book"
      case .FollowAuthor:
        return "Follow Author"
      case .FollowPenName:
        return "Follow Pen Name"
      case .BuyThisBook:
        return "BuyT his Book"
      case .PullToRefresh:
        return "Pull To Refresh"
      case .LoadMore:
        return "Load More"
      }
    }
  }
}
