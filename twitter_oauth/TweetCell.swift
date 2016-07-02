//
//  TweetCell.swift
//  twitter_oauth
//
//  Created by Rohan Y. Shah on 7/1/16.
//  Copyright © 2016 Rohan Y. Shah. All rights reserved.
//

import UIKit
import SCLAlertView

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var retweetLabel: UILabel!
    
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    
    
    
    var tweet: Tweet! {
        didSet {
            
            self.userImage.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!)!)
            self.nameLabel.text = (tweet?.user!.name)!
            self.screenNameLabel.text = "@\(tweet.user!.screenname!)"
            self.messageLabel.text = tweet?.text
            self.timeLabel.text = "\(timeAgoSinceDate((tweet?.createdAt)!, numericDates: false))"
            
            if tweet.retweeted! {
                self.retweetButton.setImage(UIImage(named: "retweet-action-on"), forState: .Normal)
                self.retweetLabel.textColor = UIColor(red: 0, green: 207/255.0, blue: 141/255.0, alpha: 1)
                self.retweetLabel.text = "\(tweet.retweetCount!)"
            } else {
                self.retweetButton.setImage(UIImage(named: "retweet-action"), forState: .Normal)
                self.retweetLabel.textColor = UIColor(red: 169/255.0, green: 184/255.0, blue: 193/255.0, alpha: 1)
                self.retweetLabel.text = "\(tweet.retweetCount!)"
            }
            
            if  tweet.favorited! {
                self.likeButton.setImage(UIImage(named: "like-action-on"), forState: .Normal)
                self.favoriteLabel.textColor = UIColor(red: 238/255.0, green: 22/255.0, blue: 79/255.0, alpha: 1)
                self.favoriteLabel.text = "\(tweet.favoriteCount!)"
            } else {
                self.likeButton.setImage(UIImage(named: "like-action"), forState: .Normal)
                self.favoriteLabel.textColor = UIColor(red: 169/255.0, green: 184/255.0, blue: 193/255.0, alpha: 1)
                self.favoriteLabel.text = "\(tweet.favoriteCount!)"
            }
        }
    }
    
    
    func timeAgoSinceDate(date:NSDate, numericDates:Bool) -> String {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components([NSCalendarUnit.Minute , NSCalendarUnit.Hour , NSCalendarUnit.Day , NSCalendarUnit.WeekOfYear , NSCalendarUnit.Month , NSCalendarUnit.Year , NSCalendarUnit.Second], fromDate: earliest, toDate: latest, options: NSCalendarOptions())
        
        if (components.year >= 2) {
            return "\(components.year)y"
        } else if (components.year >= 1){
            if (numericDates){
                return "1y"
            } else {
                return "1y"
            }
        } else if (components.month >= 2) {
            return "\(components.month)m"
        } else if (components.month >= 1){
            if (numericDates){
                return "1m"
            } else {
                return "1m"
            }
        } else if (components.weekOfYear >= 2) {
            return "\(components.weekOfYear)w"
        } else if (components.weekOfYear >= 1){
            if (numericDates){
                return "1w"
            } else {
                return "1w"
            }
        } else if (components.day >= 2) {
            return "\(components.day)d"
        } else if (components.day >= 1){
            if (numericDates){
                return "1d"
            } else {
                return "1d"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour)h"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1h"
            } else {
                return "1h"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute)m"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1m"
            } else {
                return "1m"
            }
        } else if (components.second >= 3) {
            return "\(components.second)s"
        } else {
            return "now"
        }
        
    }
    
    
    
    @IBAction func replyClicked(sender: AnyObject) {
        // post to tweet
//        self.performSegueWithIdentifier("reply", sender: self)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let cell = sender as? UITableViewCell {
//            let row = tableView.indexPathForCell(cell)!.row
//            if segue.identifier == "details" {
//                let vc = segue.destinationViewController as! DetailViewController
//                vc.tweet = tweets![row]
//            }
//        }
//        
//    }
    
    @IBAction func retweetClicked(sender: AnyObject) {
        var id = tweet.tweetID
        
        if tweet!.retweeted! {
            TwitterClient.sharedInstance.sendUnRetweetWithCompletion((tweet.tweetID)!, completion: { (response, error) -> () in
                self.retweetButton.setImage(UIImage(named: "retweet-action"), forState: .Normal)
                self.tweet!.retweetCount! -= 1
                self.tweet?.retweeted = false
                self.retweetLabel.textColor = UIColor(red: 169/255.0, green: 184/255.0, blue: 193/255.0, alpha: 1)
                self.retweetLabel.text = "\((self.tweet?.retweetCount!)!)"
            })
            
        } else {
            TwitterClient.sharedInstance.sendRetweetWithCompletion(tweet.tweetID!) {
                (error: NSError?) in
                if error == nil {
                    print("retweet suceeded")
//                    SCLAlertView().showInfo("Retweeted", subTitle: "Successful")
                    self.retweetButton.setImage(UIImage(named: "retweet-action-on"), forState: .Normal)
                    self.tweet.retweeted = true
                    self.tweet.retweetCount! += 1
                    self.tweet?.retweeted = true
                    self.retweetLabel.textColor = UIColor(red: 0, green: 207/255.0, blue: 141/255.0, alpha: 1)
                    self.retweetLabel.text = "\((self.tweet?.retweetCount!)!)"
                } else {
                    print("retweet failed")
                }
            }
        }
    }
    
    @IBAction func likeClicked(sender: AnyObject) {
        var id = tweet.tweetID
        
        // if already liked - call GET favorites/list to find out by matching twitter id
        // unfavorite - POST favorites/destroy
        
        if tweet!.favorited! {
            TwitterClient.sharedInstance.unFavoriteTweetWithCompletion((tweet?.tweetID)!, completion: { (response, error) -> () in
                self.likeButton.setImage(UIImage(named: "like-action"), forState: .Normal)
                self.tweet?.favoriteCount! -= 1
                self.tweet!.favorited = false
                self.favoriteLabel.textColor = UIColor(red: 169/255.0, green: 184/255.0, blue: 193/255.0, alpha: 1)
                self.favoriteLabel.text = "\((self.tweet?.favoriteCount!)!)"
            })
            
        } else {
            TwitterClient.sharedInstance.favoriteTweetWithCompletion(tweet.tweetID!) {
                (error: NSError?) in
                if error == nil {
                    print("favorting tweet succeeded")
//                    SCLAlertView().showInfo("Liked", subTitle: "Successful")
                    self.likeButton.setImage(UIImage(named: "like-action-on"), forState: .Normal)
                    self.tweet.favoriteCount! += 1
                    self.tweet.favorited = true
                    self.favoriteLabel.textColor = UIColor(red: 238/255.0, green: 22/255.0, blue: 79/255.0, alpha: 1)
                    self.favoriteLabel.text = "\((self.tweet?.favoriteCount!)!)"
                } else {
                    print("favoriting tweet failed")
                }
            }
        }
    }
    
    
    
    override func awakeFromNib() {
        userImage.layer.cornerRadius = 8
        userImage.clipsToBounds = true
        super.awakeFromNib()
    }
}
