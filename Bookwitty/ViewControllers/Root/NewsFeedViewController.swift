//
//  NewsFeedViewController.swift
//  Bookwitty
//
//  Created by Shafic Hariri on 2/8/17.
//  Copyright © 2017 Keeward. All rights reserved.
//
import UIKit
import AsyncDisplayKit

class NewsFeedViewController: ASViewController<ASCollectionNode> {
  let collectionNode: ASCollectionNode
  let flowLayout: UICollectionViewFlowLayout

  let data = ["","","","","","","","","","","","","","",""]

  init() {
    flowLayout = UICollectionViewFlowLayout()
    let externalMargin = ThemeManager.shared.currentTheme.cardExternalMargin()
    flowLayout.sectionInset = UIEdgeInsets(top: externalMargin/2, left: 0, bottom: externalMargin/2, right: 0)
    collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)

    super.init(node: collectionNode)

    collectionNode.delegate = self
    flowLayout.minimumInteritemSpacing  = 1
    flowLayout.minimumLineSpacing       = 1
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionNode.delegate = self
    collectionNode.dataSource = self
  }
}

extension NewsFeedViewController: ASCollectionDataSource {
  func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
    return data.count > 0 ? 1 : 0
  }

  func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
    return data.count
  }

  func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    let index = indexPath.row
    
    return {
      let cell: BaseCardPostNode
      switch index {
      case 19:
        let topicCell: ReadingListCardPostCellNode = ReadingListCardPostCellNode()
        topicCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        topicCell.node.articleTitle = "Think Metallica & Lady Gaga’s performance at the Grammys will be weird? This isn’t even the weirdest collaboration they’ve given us."
        topicCell.node.articleDescription = "The Grammys have sandwiched together some unorthodox, yet delicious, combinations in the past. Each year, the ceremony seems to one-up itself with a radical recipe of rap and jazz, or country and R&B, or something wacky like polka and ska. Their pairings are like banana and bacon -- you don’t think they’d taste well together, but they actually mesh pretty decently once you try them."
        topicCell.node.setTopicStatistics(numberOfPosts: "73")
        topicCell.articleCommentsSummary = "Joanna and 4 others you know commented on this"
        cell = topicCell
      case 18:
        let profileCell: ProfileCardPostCellNode = ProfileCardPostCellNode()
        profileCell.node.imageUrl = "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png"
        profileCell.node.followersCount = nil
        profileCell.node.userName = "Marwan Al Toutoun Nji"
        profileCell.node.articleDescription = "I am an Art'Tist"
        cell = profileCell
      case 17:
        let profileCell: ProfileCardPostCellNode = ProfileCardPostCellNode()
        profileCell.node.imageUrl = "https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png"
        profileCell.node.followersCount = "1564"
        profileCell.node.userName = "Shafic Abed Al'Moutaleb Al'Hariri"
        profileCell.node.articleDescription = "The Grammys have sandwiched together some unorthodox, yet delicious, combinations in the past. Each year, the ceremony seems to one-up itself with a radical recipe of rap and jazz, or country and R&B, or something wacky like polka and ska. Their pairings are like banana and bacon -- you don’t think they’d taste well together, but they actually mesh pretty decently once you try them."
        cell = profileCell
      case 16:
        let topicCell: TopicCardPostCellNode = TopicCardPostCellNode()
        topicCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        topicCell.node.articleTitle = "Think Metallica & Lady Gaga’s performance at the Grammys will be weird? This isn’t even the weirdest collaboration they’ve given us."
        topicCell.node.articleDescription = "The Grammys have sandwiched together some unorthodox, yet delicious, combinations in the past. Each year, the ceremony seems to one-up itself with a radical recipe of rap and jazz, or country and R&B, or something wacky like polka and ska. Their pairings are like banana and bacon -- you don’t think they’d taste well together, but they actually mesh pretty decently once you try them."
        topicCell.node.imageUrl = "https://www.billboard.com/files/styles/article_main_image/public/media/metallica-opera-house-nov-2016-billboard-1548.jpg"
        topicCell.node.setTopicStatistics(numberOfPosts: "73")
        topicCell.articleCommentsSummary = "Joanna and 4 others you know commented on this"
        topicCell.node.subImageUrl = "https://s-media-cache-ak0.pinimg.com/736x/61/81/9b/61819b3a8b1ad89bbfb541e7fc15025b.jpg"
        cell = topicCell
      case 15:
        let topicCell: TopicCardPostCellNode = TopicCardPostCellNode()
        topicCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        topicCell.node.articleTitle = nil
        topicCell.node.articleDescription = "The Grammys have sandwiched together some unorthodox, yet delicious, combinations in the past. Each year, the ceremony seems to one-up itself with a radical recipe of rap and jazz, or country and R&B, or something wacky like polka and ska. Their pairings are like banana and bacon -- you don’t think they’d taste well together, but they actually mesh pretty decently once you try them."
        topicCell.node.imageUrl = nil
        topicCell.node.setTopicStatistics(numberOfBooks: "18", numberOfFollowers: "1230")
        topicCell.articleCommentsSummary = "Joanna and 4 others you know commented on this"
        cell = topicCell
      case 14:
        let topicCell: TopicCardPostCellNode = TopicCardPostCellNode()
        topicCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        topicCell.node.articleTitle = "Think Metallica & Lady Gaga’s performance at the Grammys will be weird? This isn’t even the weirdest collaboration they’ve given us."
        topicCell.node.setTopicStatistics(numberOfPosts: "73", numberOfBooks: "18", numberOfFollowers: "1230")
        topicCell.node.articleDescription = nil
        topicCell.node.imageUrl = nil
        topicCell.articleCommentsSummary = "Joanna and 4 others you know commented on this"
        cell = topicCell
      case 13:
        let topicCell: TopicCardPostCellNode = TopicCardPostCellNode()
        topicCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        topicCell.node.articleTitle = "Think Metallica & Lady Gaga’s performance at the Grammys will be weird? This isn’t even the weirdest collaboration they’ve given us."
        topicCell.node.articleDescription = "The Grammys have sandwiched together some unorthodox, yet delicious, combinations in the past. Each year, the ceremony seems to one-up itself with a radical recipe of rap and jazz, or country and R&B, or something wacky like polka and ska. Their pairings are like banana and bacon -- you don’t think they’d taste well together, but they actually mesh pretty decently once you try them."
        topicCell.node.imageUrl = "https://www.billboard.com/files/styles/article_main_image/public/media/metallica-opera-house-nov-2016-billboard-1548.jpg"
        topicCell.node.setTopicStatistics(numberOfPosts: "73", numberOfBooks: "5")
        topicCell.articleCommentsSummary = nil
        cell = topicCell
      case 0:
        let topicCell: TopicCardPostCellNode = TopicCardPostCellNode()
        topicCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        topicCell.node.articleTitle = "Think Metallica & Lady Gaga’s performance at the Grammys will be weird? This isn’t even the weirdest collaboration they’ve given us."
        topicCell.node.articleDescription = "The Grammys have sandwiched together some unorthodox, yet delicious, combinations in the past. Each year, the ceremony seems to one-up itself with a radical recipe of rap and jazz, or country and R&B, or something wacky like polka and ska. Their pairings are like banana and bacon -- you don’t think they’d taste well together, but they actually mesh pretty decently once you try them."
        topicCell.node.imageUrl = "https://www.billboard.com/files/styles/article_main_image/public/media/metallica-opera-house-nov-2016-billboard-1548.jpg"
        topicCell.articleCommentsSummary = "Joanna and 4 others you know commented on this"
        cell = topicCell
      case 1:
        let articleCell: ArticleCardPostCellNode = ArticleCardPostCellNode()
        articleCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        articleCell.node.articleTitle = "Think Metallica & Lady Gaga’s performance at the Grammys will be weird? This isn’t even the weirdest collaboration they’ve given us."
        articleCell.node.articleDescription = "The Grammys have sandwiched together some unorthodox, yet delicious, combinations in the past. Each year, the ceremony seems to one-up itself with a radical recipe of rap and jazz, or country and R&B, or something wacky like polka and ska. Their pairings are like banana and bacon -- you don’t think they’d taste well together, but they actually mesh pretty decently once you try them."
        articleCell.node.imageUrl = "https://www.billboard.com/files/styles/article_main_image/public/media/metallica-opera-house-nov-2016-billboard-1548.jpg"
        articleCell.articleCommentsSummary = "Joanna and 4 others you know commented on this"
        cell = articleCell
        cell.supplementaryElementKind = "HEADER"
      case 2:
        let photoCell = PhotoCardPostCellNode()
        photoCell.postInfoData = CardPostInfoNodeData("Michel","December 1, 2016","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        photoCell.node.imageUrl = "https://www.accompany.com/wp-content/uploads/accompany-relationship-management-book-recommendations-600x400.jpg"
        photoCell.articleCommentsSummary = "Shafic and 2 others you know commented on this"
        cell = photoCell
      case 3:
        let articleCell: ArticleCardPostCellNode = ArticleCardPostCellNode()
        articleCell.postInfoData = CardPostInfoNodeData("Shafic","December 12, 2014","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        articleCell.node.articleTitle = "What happens after companies jettison traditional year-end evaluations? Ahead of the curve: The future of performance management"
        articleCell.node.articleDescription = "The worst-kept secret in companies has long been the fact that the yearly ritual of evaluating (and sometimes rating and ranking) the performance of employees epitomizes the absurdities of corporate life. Managers and staff alike too often view performance management as time consuming, excessively subjective, demotivating, and ultimately unhelpful. In these cases, it does little to improve the performance of employees. It may even undermine their performance as they struggle with ratings, worry about compensation, and try to make sense of performance feedback."
        articleCell.articleCommentsSummary = "Marilyn commented on this"
        articleCell.node.imageUrl = ""
        cell = articleCell
      case 4:
        let videoCell = VideoCardPostCellNode()
        videoCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        videoCell.node.articleTitle = "Live version of 'Iron Sky' from Paolo's album 'Caustic Love'. Recorded live at Abbey Road, London."
        videoCell.node.articleDescription = "“Iron Sky” may very well have started out as a “slow burner” single off of Scottish singer/ songwriter Paolo Nutini’s album Caustic Love, but it has combusted into one hell of a blaze. The song starts with a low deep bass; just a few notes to introduce the psychedelic guitar which gives way to Paolo Nutini’s voice. The song cries with lyrics that tell a story to rise above the Iron Sky of suppression and pollution that is slowly taking over society’s mind. “Iron sky” is a song that is a compelling stirring blend of conscious-soul subject wrapped up in a deep, deep-soul style. Paolo’s strong lyrical message echoes the voices of yesterday like Curtis Mayfield or Marvin Gay with the same smooth, seductive gut intensity."
        videoCell.node.imageUrl = "https://i3.ytimg.com/vi/ELKbtFljucQ/hqdefault.jpg"
        videoCell.articleCommentsSummary = "Shafic and 10 others you know commented on this"
        cell = videoCell
      case 5:
        let linkCell = LinkCardPostCellNode()
        linkCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        linkCell.node.linkUrl = "https://medium.com/pointer-io/the-engineers-guide-to-companies-ed859187f78c#.sthe5orpf"
        linkCell.node.articleTitle = "The Engineer’s Guide to Companies"
        linkCell.node.articleDescription = "In my previous, totally important technology business article, The Engineer’s Guide to Management, I explained how massive management infrastructure is necessary for running an effective engineering organization. If you didn’t read that other article, you probably should."
        cell = linkCell
      case 6:
        let linkCell = LinkCardPostCellNode()
        linkCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        linkCell.node.linkUrl = nil
        linkCell.node.articleTitle = nil
        linkCell.node.articleDescription = "In my previous, totally important technology business article, The Engineer’s Guide to Management, I explained how massive management infrastructure is necessary for running an effective engineering organization. If you didn’t read that other article, you probably should."
        cell = linkCell
      case 7:
        let linkCell = LinkCardPostCellNode()
        linkCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        linkCell.node.linkUrl = "https://soundcloud.com/superduperkylemusic/kyle-ispy-feat-lil-yachty"
        linkCell.node.articleTitle = nil
        linkCell.node.articleDescription = nil
        cell = linkCell
      case 8:
        let linkCell = LinkCardPostCellNode()
        linkCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        linkCell.node.linkUrl = "https://medium.com/pointer-io/the-engineers-guide-to-companies-ed859187f78c#.sthe5orpf"
        linkCell.node.articleTitle = nil
        linkCell.node.articleDescription = "In my previous, totally important technology business article, The Engineer’s Guide to Management, I explained how massive management infrastructure is necessary for running an effective engineering organization. If you didn’t read that other article, you probably should."
        linkCell.articleCommentsSummary = nil
        cell = linkCell
      case 9:
        let linkCell = LinkCardPostCellNode()
        linkCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        linkCell.node.linkUrl = nil
        linkCell.node.articleTitle = "The Engineer’s Guide to Companies"
        linkCell.node.articleDescription = "In my previous, totally important technology business article, The Engineer’s Guide to Management, I explained how massive management infrastructure is necessary for running an effective engineering organization. If you didn’t read that other article, you probably should."
        linkCell.articleCommentsSummary = nil
        cell = linkCell
      case 10:
        let linkCell = LinkCardPostCellNode()
        linkCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        linkCell.node.linkUrl = nil
        linkCell.node.articleTitle = "The Engineer’s Guide to Companies"
        linkCell.node.articleDescription = nil
        linkCell.articleCommentsSummary = nil
        cell = linkCell
      case 11:
        let quoteCell = QuoteCardPostCellNode()
        quoteCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        quoteCell.node.articleQuotePublisher = "Woody Allen"
        quoteCell.node.articleQuote = "“ I'm not afraid to die, I just don't want to be here when it happens ”"
        quoteCell.articleCommentsSummary = "Shafic and 10 others you know commented on this"
        cell = quoteCell
      case 12:
        let quoteCell = QuoteCardPostCellNode()
        quoteCell.postInfoData = CardPostInfoNodeData("Charles","December 2, 2020","https://ocw.mit.edu/faculty/michael-cuthbert/cuthbert.png")
        quoteCell.node.articleQuotePublisher = "Norman Cousins"
        quoteCell.node.articleQuote = "“ Death is not the greatest loss in life. The greatest loss is what dies inside us while we live. ”"
        quoteCell.articleCommentsSummary = nil
        cell = quoteCell
      default:
        cell = BaseCardPostNode()
      }
      return cell
    }
  }
}

extension NewsFeedViewController: ASCollectionDelegate {
  public func collectionNode(_ collectionNode: ASCollectionNode, constrainedSizeForItemAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRange(
      min: CGSize(width: collectionNode.frame.width, height: 0),
      max: CGSize(width: collectionNode.frame.width, height: .infinity)
    )
  }
}
