//
//  ProfileViewController.swift
//  twitter_oauth
//
//  Created by Rohan Y. Shah on 7/1/16.
//  Copyright © 2016 Rohan Y. Shah. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    
    var tweets : [Tweet]?
    var user : User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        if(user != nil) {
            
            userName.text = user.name! as String
            screenName.text = "@\(user.screenname!)"
            
            followersLabel.text = numberToUnits(user.followersCount!) as String
            
            followingLabel.text = numberToUnits(user.followingCount!) as String
            
            tweetsLabel.text = numberToUnits(user.tweets!) as String
            
            let banner = (user.profileBannerURL != nil) ? NSURL(string: user.profileBannerURL! as String) : NSURL(string: user.backgroundImageURL! as String)
            
            self.backgroundImageView.setImageWithURL(banner!)
            profileImage.setImageWithURL(NSURL(string: user.profileImageUrl! as String)!)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyTweetsCell") as! MyTweetsCell
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweetsArray = self.tweets  {
            return tweetsArray.count
        } else {
            return 0
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberToUnits(count : Int) -> NSString {
        
        print(count)
        switch count {
        case 0...999:
            return String(count)
        case 1000...999999:
            let num = count/1000
            return "\(num)k"
        case 1,000,000...999999999:
            let num = count/1000000
            return "\(num)m"
        default:
            return String(count)
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
