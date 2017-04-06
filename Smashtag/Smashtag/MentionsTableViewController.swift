//
//  MentionsTableViewController.swift
//  Smashtag
//
//  Created by certainly on 2017/4/5.
//  Copyright © 2017年 certainly. All rights reserved.
//

import UIKit
import Twitter

class MentionsTableViewController: UITableViewController {
    
    fileprivate var mentions = [Mentions]()
    
    fileprivate struct Mentions: CustomStringConvertible
    {
        var title: String
        var data: [MentionItem]
        var description: String { return "\(title): \(data)" }
    }
    
    fileprivate enum MentionItem: CustomStringConvertible
    {
        case keyword(String)
        case image(URL, Double)
        var description: String {
            switch self {
            // For hashtags, urls and user screen names
            case .keyword(let keyword): return keyword
            // For images
            case .image(let url, _): return url.path
            }
        }
    }
    
    fileprivate struct Title {
        static let images = "Images"
        static let urls = "URLs"
        static let hashtags = "Hashtags"
        static let users = "Users"
    }
    
    
    fileprivate struct Storyboard {
        static let KeywordCellIdentifier = "Keyword Cell"
        static let KeywordSegue = "from keyword"
        static let ImageCellIdentifier = "Image Cell"
        static let ImageSegue = "show image"
        static let SafariSegue = "show url"
    }
    
    var tweet: Twitter.Tweet? {
        didSet {
            // Transform Tweet into internal data structure [Mentions]
            title = tweet?.user.screenName
            if let media = tweet?.media, !media.isEmpty {
                mentions.append(Mentions(title: Title.images,
                                         data: media.map { MentionItem.image($0.url, $0.aspectRatio) }))
            }
            if let urls = tweet?.urls, !urls.isEmpty{
                mentions.append(Mentions(title: Title.urls,
                                         data: urls.map { MentionItem.keyword($0.keyword) }))
            }
            if let hashtags = tweet?.hashtags, !hashtags.isEmpty{
                mentions.append(Mentions(title: Title.hashtags,
                                         data: hashtags.map { MentionItem.keyword($0.keyword) }))
            }
            if let users = tweet?.userMentions, !users.isEmpty{
                mentions.append(Mentions(title: Title.users,
                                         data: users.map { MentionItem.keyword($0.keyword) }))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return mentions.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mentions[section].data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .keyword(let keyword):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.KeywordCellIdentifier, for: indexPath)
            cell.textLabel?.text = keyword
            return cell
        case .image(let url, _):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ImageCellIdentifier, for: indexPath)
            if let imageCell = cell as? ImageTableViewCell {
                imageCell.imageUrl = url
            }
            return cell
        }


    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mention = mentions[indexPath.section].data[indexPath.row]
        switch mention {
        case .image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].title
    }
    
    
    

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Storyboard.KeywordSegue {
                if let ttvc = segue.destination as? SmashTweetTableViewController,
                    let cell = sender as? UITableViewCell,
                    let text = cell.textLabel?.text {
                    ttvc.searchText = text
                    
                }
            } else if identifier == Storyboard.ImageSegue {
                if let ivc = segue.destination as? ImageViewController,
                    let cell = sender as? ImageTableViewCell {

                        ivc.imageURL = cell.imageUrl
                        ivc.title = title
                    }
                    
            }
        }
    }
    
    // We don't want to perform a segue for URL as for a .Keyword
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        if identifier == Storyboard.KeywordSegue {
            if let cell = sender as? UITableViewCell,
                let indexPath =  tableView.indexPath(for: cell),
                let url = cell.textLabel?.text, mentions[indexPath.section].title == Title.urls {
                if url.hasPrefix("http") {
                    UIApplication.shared.open(URL(string: url)!)
                    return false
                }
            }
        }
        return true
    }
    

}
