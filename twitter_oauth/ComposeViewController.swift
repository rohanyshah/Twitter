//
//  ComposeViewController.swift
//  twitter_oauth
//
//  Created by Rohan Y. Shah on 7/1/16.
//  Copyright © 2016 Rohan Y. Shah. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var tweetText: UITextView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var screenLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var countLabel: UILabel!
    
    var delegate : ComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countLabel.hidden = true
        tweetText.delegate = self
        nameLabel.text = User.currentUser?.name
        screenLabel.text = "@\((User.currentUser?.screenname)!)"
        User.currentUser?.profileImageUrl
        self.profileImage.setImageWithURL(NSURL(string: (User.currentUser?.profileImageUrl!)!)!)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func tweetClicked(sender: AnyObject) {
        let status = tweetText.text
        if(!status.isEmpty) {
            TwitterClient.sharedInstance.postTweetWithCompletion(status!, completion: {(
                error) -> () in
                if error == nil {
                    self.delegate?.didTweetSuceed(self)
                }
            })
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            print("nothing to post")
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if ((tweetText.text.characters.count) > 140) {
            tweetText.text = tweetText.text.substringToIndex(tweetText.text.startIndex.advancedBy(140))
        } else if((tweetText.text.characters.count) == 140) {
            countLabel.hidden = true
        } else {
            let count = 140 - tweetText.text.characters.count
            countLabel.hidden = false
            countLabel.text = String(count)
        }
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

protocol ComposeViewControllerDelegate {
    func didTweetSuceed(sender: ComposeViewController)
}
