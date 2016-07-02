//
//  DetailViewController.swift
//  twitter_oauth
//
//  Created by Rohan Y. Shah on 7/1/16.
//  Copyright © 2016 Rohan Y. Shah. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
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
    
    var tweet: Tweet!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userImage.setImageWithURL(NSURL(string: tweet.user!.profileImageUrl!)!)
        self.nameLabel.text = (tweet?.user!.name)!
        self.screenNameLabel.text = "@\(tweet.user!.screenname!)"
        self.messageLabel.text = tweet?.text
        
        self.timeLabel.text = String((tweet?.createdAt)!)
        
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
