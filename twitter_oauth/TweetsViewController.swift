//
//  TweetsViewController.swift
//  twitter_oauth
//
//  Created by Rohan Y. Shah on 7/1/16.
//  Copyright © 2016 Rohan Y. Shah. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import DGActivityIndicatorView
import ElasticTransition

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeViewControllerDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var numPages = 0
    var tweets: [Tweet]?
    var loadingMoreView:InfiniteScrollActivityView?
    var isMoreDataLoading = false
    
    func didTweetSuceed(sender: ComposeViewController) {
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        retrieve()
        
        let image = UIImageView(image: UIImage(named: "Twitter_logo_blue_48"))
        self.navigationItem.titleView = image

        
        // Pull to refresh
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = UIColor.whiteColor()
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            self!.refresh()
            self?.tableView.dg_stopLoading()
            }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(UIColor(red: 51/255, green: 139/255, blue: 182/255, alpha: 1))
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            let row = tableView.indexPathForCell(cell)!.row
            if segue.identifier == "details" {
                let vc = segue.destinationViewController as! DetailViewController
                vc.tweet = tweets![row]
            }
        }
        
        if (segue.identifier! == "profile") {
            let profileVC = segue.destinationViewController as! ProfileViewController
            profileVC.user = sender as! User
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        self.performSegueWithIdentifier("details", sender: currentCell)
    }
    
    func loadMoreData() {
        let parameters = NSMutableDictionary()
        numPages += 20
        parameters["count"] = numPages
        
        TwitterClient.sharedInstance.homeTimelineWithCompletion(parameters, completion: {(tweets,
            error) -> () in
            self.tweets = tweets
            self.isMoreDataLoading = false
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
            // reload tableview
            // understand post logic
        })
    }
    
    func refresh () {
        let parameters = NSMutableDictionary()
        parameters["count"] = numPages
        TwitterClient.sharedInstance.homeTimelineWithCompletion(parameters, completion: {(tweets,
            error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            // reload tableview
            // understand post logic
        })

    }
    
    func retrieve() {
        
        numPages = 20
        
        TwitterClient.sharedInstance.homeTimelineWithCompletion(nil, completion: {(tweets,
            error) -> () in
            self.tweets = tweets
            self.tableView.reloadData()
            // reload tableview
            // understand post logic
        })
    }
    
    // Infinite scroll
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
//                self.pages += 1
                loadMoreData()
                // ... Code to load more results ...
            }
            // ... Code to load more results ...
            
        }
    }
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil{
            return (tweets?.count)!
        } else {
            return 0
        }
    }
    
    func profileImageTapped(gesture: UITapGestureRecognizer) {
        let profileView = gesture.view as! UIImageView
        print(self.tweets![profileView.tag].user!.name)
        self.performSegueWithIdentifier("profile", sender: self.tweets![profileView.tag].user!)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        let tapGesture = UITapGestureRecognizer(target: self, action:Selector("profileImageTapped:"))
        cell.userImage.userInteractionEnabled = true
        cell.userImage.addGestureRecognizer(tapGesture)
        cell.userImage!.tag = indexPath.row
        cell.tweet = tweets![indexPath.row]
        return cell
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        tableView.dg_removePullToRefresh()
    }
}

extension UIScrollView {
    // to fix a problem where all the constraints of the tableview
    // are deleted
    func dg_stopScrollingAnimation() {}
}
