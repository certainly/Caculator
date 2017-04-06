//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by certainly on 2017/3/30.
//  Copyright © 2017年 certainly. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    @IBOutlet weak var tweetProfileImageView: UIImageView!

    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!

    var tweet: Twitter.Tweet? { didSet { updateUI() } }
    
    private func updateUI() {
        if tweet != nil {
            tweetTextLabel.attributedText = getColorfulTextLabel(tweet!)
        }
//        tweetTextLabel.text = tweet?.text
        tweetUserLabel.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: profileImageURL) {
                    DispatchQueue.main.async { [weak self] in
                        self?.tweetProfileImageView.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView.image = nil
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel.text = nil  
        }
    }
    
    
    fileprivate struct Color {
        static let user = UIColor.purple
        static let hashtag = UIColor.darkGray
        static let url = UIColor.blue
    }
    
    
    private func getColorfulTextLabel(_ tweet: Twitter.Tweet) -> NSMutableAttributedString {
        var text = tweet.text
        for _ in tweet.media {
            text += " 📷"
        }
        
        // Enhance Smashtag from lecture to highlight (in a different color for each) hashtags,
        // urls and user screen names mentioned in the text of each Tweet
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.setMensionsColor(tweet.hashtags, color: Color.hashtag)
        attributedText.setMensionsColor(tweet.urls, color: Color.url)
        attributedText.setMensionsColor(tweet.userMentions, color: Color.user)
        
        return attributedText

    }

}

private extension NSMutableAttributedString {
    func setMensionsColor(_ mensions: [Mention], color: UIColor) {
        for mension in mensions {
            addAttribute(NSForegroundColorAttributeName, value: color, range: mension.nsrange)
        }
    }
}
