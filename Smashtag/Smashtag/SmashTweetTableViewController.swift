//
//  SmashTweetTableViewController.swift
//  Smashtag
//
//  Created by certainly on 2017/3/31.
//  Copyright © 2017年 certainly. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class SmashTweetTableViewController: TweetTableViewController {
    
    var container: NSPersistentContainer? =
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    
    override func insertTweets(_ newTweets: [Twitter.Tweet]) {
        super.insertTweets(newTweets)
        updateDatabase(with: newTweets)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        searchText = "#catpic"
    }
    
    private func updateDatabase(with tweets: [Twitter.Tweet]) {
        container?.performBackgroundTask { [weak self] context in
            for twitterInfo in tweets {
                _ = try? Tweet.findOrCreateTweet(matching: twitterInfo, in: context)
            }
            try? context.save()
            self?.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if Thread.isMainThread {
                    print("On main thread")
                } else {
                    print("Off main thread")
                }
                let request: NSFetchRequest<Tweet> = Tweet.fetchRequest()
                if let tweetCount = (try? context.fetch(request))?.count {
                    print("\(tweetCount) tweets")
                }
                if let tweeterCount = try? context.count(for: TwitterUser.fetchRequest()) {
                    print("\(tweeterCount) Twitter users")
                }
            }
        }
    }
    
    // MARK: Constants
    
    fileprivate struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let MentionsSegueIdentifier = "show mentions"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Tweeters Mentioning Search Term" {
            if let tweetersTVC = segue.destination as? SmashTweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.container = container
            }
        } else if segue.identifier == Storyboard.MentionsSegueIdentifier {
            if let mtvc = segue.destination as? MentionsTableViewController {
                if let cell = sender as? TweetTableViewCell {
                    mtvc.tweet = cell.tweet
                }
            }

        }
    }
}
