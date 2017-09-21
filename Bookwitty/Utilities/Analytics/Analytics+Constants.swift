//
//  Analytics+Constants.swift
//  Bookwitty
//
//  Created by Marwan on 1/18/17.
//  Copyright © 2017 Keeward. All rights reserved.
//

import Foundation

extension Analytics {

  enum Field: Int {
    case ApplicationVersion
    case UserIdentifier
  }

  struct Event {
    let category: Category
    let action: Action
    let name: String
    let value: Double
    let info: [String : String]

    init(category: Category, action: Action, name: String = "", value: Double = 0.0, info: [String : String] = [:]) {
      self.category = category
      self.action = action
      self.name = name
      self.value = value
      self.info = info
    }
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
    case Onboarding
    case PenNamesList
    case Tag

    //Use in switch cases default clause
    case Default

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
      case .Onboarding:
        return "Onboarding"
      case .PenNamesList:
        return "Pen Names List"
      case .Tag:
        return "Tag"
      case .Default:
        return "[DEFAULT]"
      }
    }
  }
  
  enum Action {
    case SignIn
    case ResetPassword
    case Register
    case EditPenName
    case CreatePenName
    case SwitchCommentsEmailNotification
    case SwitchFollowersEmailNotification
    case SwitchNewsletterEmailNotification
    case ChangePassword
    case SignOut
    //
    case Wit
    case Unwit
    case WitComment
    case UnwitComment
    //
    case AddComment
    case PublishComment
    case ReplyToComment
    //
    case Share
    //
    case SelectPenName  
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
    case GoToContent
    case GoToBooks
    case GoToPages
    case GoToFilters
    case GoToFormats
    //
    case ChooseEdition
    case ChoosePreferredFormat
    //
    case ViewBanner
    //
    case ViewTopComment
    //
    case ViewAllTopics
    case ViewAllReadingLists
    case ViewAllReadingListContent
    case ViewAllRelatedBooks
    case ViewAllRelatedPosts
    case ViewAllComments
    case ViewAllCategories
    case ViewAllBooks
    case ViewAllReplies
    //
    case Follow
    case FollowTopic
    case FollowTopicBook
    case FollowAuthor
    case FollowPenName
    case Unfollow
    case UnfollowTopic
    case UnfollowTopicBook
    case UnfollowAuthor
    case UnfollowPenName
    //
    case BuyThisBook
    //
    case PullToRefresh
    case LoadMore
    case LoadMoreComments
    //
    case SearchOnBookwitty
    //
    case Report
    //
    case Default

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
      case .CreatePenName:
        return "Create Pen Name"
      case .SwitchCommentsEmailNotification:
        return "Switch Email Notification - Comments"
      case .SwitchFollowersEmailNotification:
        return "Switch Email Notification - Followers"
      case .SwitchNewsletterEmailNotification:
        return "Switch Email Notification - Newsletter"
      case .ChooseEdition:
        return "Choose Edition"
      case .ChangePassword:
        return "Change Password"
      case .ChoosePreferredFormat:
        return "Choose Preferred Format"
      case .SignOut:
        return "Sign Out"
      case .Wit:
        return "Wit"
      case .Unwit:
        return "Unwit"
      case .WitComment:
        return "Wit Comment"
      case .UnwitComment:
        return "Unwit Comment"
      case .AddComment:
        return "Add Comment"
      case .PublishComment:
        return "Publish Comment"
      case .ReplyToComment:
        return "Reply To Comment"
      case .Share:
        return "Share"
      case .SelectPenName:
        return "Select Pen Name"
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
      case .GoToFormats:
        return "Go To Formats"
      case .GoToRelatedCategories:
        return "Go To Related Categories"
      case .GoToBagOnWebsite:
        return "Go To Bag On Website"
      case .GoToContent:
        return "Go To Content"
      case .GoToBooks:
        return "Go To Books"
      case .GoToPages:
        return "Go To Pages"
      case .GoToFilters:
        return "Go To Filters"
      case .ViewBanner:
        return "View Banner"
      case .ViewTopComment:
        return "View Top Comment"
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
      case .ViewAllReplies:
        return "View All Replies"
      case .Follow:
        return "Follow"
      case .FollowTopic:
        return "Follow Topic"
      case .FollowTopicBook:
        return "Follow Topic Book"
      case .FollowAuthor:
        return "Follow Author"
      case .FollowPenName:
        return "Follow Pen Name"
      case .Unfollow:
        return "Unfollow"
      case .UnfollowTopic:
        return "Unfollow Topic"
      case .UnfollowTopicBook:
        return "Unfollow Topic Book"
      case .UnfollowAuthor:
        return "Unfollow Author"
      case .UnfollowPenName:
        return "Unfollow Pen Name"
      case .BuyThisBook:
        return "Buy This Book"
      case .PullToRefresh:
        return "Pull To Refresh"
      case .LoadMore:
        return "Load More"
      case .LoadMoreComments:
        return "Load More Comments"
      case .SearchOnBookwitty:
        return "Search On Bookwitty"
      case .Report:
        return "Report"
      case .Default:
        return "[DEFAULT]"
      }
    }
  }

  struct ScreenName {
    let name: String
    fileprivate init(name: String) {
      self.name = name
    }
  }

  struct ScreenNames {
    private init() {}
    static let Intro1 = ScreenName(name: "Intro 1")
    static let Intro2 = ScreenName(name: "Intro 2")
    static let Intro3 = ScreenName(name: "Intro 3")
    static let Intro4 = ScreenName(name: "Intro 4")
    static let Intro5 = ScreenName(name: "Intro 5")
    static let SignIn = ScreenName(name: "Sign In")
    static let ForgotYourPassword = ScreenName(name: "Forgot Your Password")
    static let Register = ScreenName(name: "Register")
    static let CountryList = ScreenName(name: "Country List")
    static let TermsOfUse = ScreenName(name: "Terms Of Use")
    static let PrivacyPolicy = ScreenName(name: "Privacy Policy")
    static let EditPenName = ScreenName(name: "Edit Pen Name")
    static let OnboardingFollowPeopleAndTopics = ScreenName(name: "Onboarding Follow People & Topics")
    static let NewsFeed = ScreenName(name: "News Feed")
    static let NewsFeedNoInternet = ScreenName(name: "News Feed - No Internet")
    static let NewsFeedError = ScreenName(name: "News Feed - Error")
    static let NewsFeedNoContent = ScreenName(name: "News Feed - No Content")
    static let Article = ScreenName(name: "Article")
    static let Image = ScreenName(name: "Image")
    static let Video = ScreenName(name: "Video")
    static let Link = ScreenName(name: "Link")
    static let Quote = ScreenName(name: "Quote")
    static let Audio = ScreenName(name: "Audio")
    static let ReadingList = ScreenName(name: "Reading List")
    static let PenName = ScreenName(name: "Pen Name")
    static let Topic  = ScreenName(name: "Topic")
    static let Author = ScreenName(name: "Author")
    static let TopicBook = ScreenName(name: "Topic Book")
    static let Contributors = ScreenName(name: "Contributors")
    static let Comments = ScreenName(name: "Comments")
    static let BookStorefront = ScreenName(name: "Book Storefront")
    static let BrowseByCategory = ScreenName(name: "Browse By Category")
    static let Category = ScreenName(name: "Category")
    static let BookProduct = ScreenName(name: "Book Product")
    static let BookDescription = ScreenName(name: "Book Description")
    static let BookDetails = ScreenName(name: "Book Details")
    static let ProductFormats = ScreenName(name: "Product Formats")
    static let FormatEditions = ScreenName(name: "Format Editions")
    static let Discover = ScreenName(name: "Discover")
    static let Bag = ScreenName(name: "Bag")
    static let Search = ScreenName(name: "Search")
    static let SearchFilter = ScreenName(name: "Search Filters")
    static let Account = ScreenName(name: "Account")
    static let Settings = ScreenName(name: "Settings")
    static let ChangePassword = ScreenName(name: "Change Password")
    static let Help = ScreenName(name: "Help")
    static let ReadingLists = ScreenName(name: "Reading Lists")
    static let BooksListing = ScreenName(name: "Books Listing")
    static let UserProfile = ScreenName(name: "User Profile")
    static let PenNameList = ScreenName(name: "Pen Name List")

    //Use in switch cases default clause
    static let Default = ScreenName(name: "[DEFAULT]")
  }
}

extension Analytics.Action {
  static func actionFrom(cardAction: CardActionBarNode.Action, with category: Analytics.Category) -> Analytics.Action {
    switch cardAction {
    case .wit:
      return .Wit
    case .unwit:
      return .Unwit
    case .comment:
      return .GoToComments
    case .share:
      return .Share
    case .follow:
      switch category {
      case .Topic:
        return .FollowTopic
      case .TopicBook:
        return .FollowTopicBook
      case .Author:
        return .FollowAuthor
      case .PenName:
        return .FollowPenName
      default:
        return .Follow
      }
    case .unfollow:
      switch category {
      case .Topic:
        return .UnfollowTopic
      case .TopicBook:
        return .UnfollowTopicBook
      case .Author:
        return .UnfollowAuthor
      case .PenName:
        return .UnfollowPenName
      default:
        return .Unfollow
      }
    case .reply:
      return .ReplyToComment
    case .more:
      return .Report
    }
  }
}
