//
//  TwitterClient.swift
//  twitter_oauth
//
//  Created by Rohan Y. Shah on 7/1/16.
//  Copyright © 2016 Rohan Y. Shah. All rights reserved.
//

import UIKit
import BDBOAuth1Manager


let twitterBaseUrl = NSURL(string: "https://api.twitter.com")
let filePath = NSBundle.mainBundle().pathForResource("keys", ofType:"plist")
let plist = NSDictionary(contentsOfFile:filePath!)
let twitterConsumerKey = plist?.objectForKey("twitterConsumerKey") as! String
let twitterConsumerSecret = plist?.objectForKey("twitterConsumerSecret") as! String

class TwitterClient: BDBOAuth1SessionManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient { // to use as singleton
        struct Static {
            static let instance = TwitterClient(
                baseURL: twitterBaseUrl,
                consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret)
        }
        
        return Static.instance
    }
    
    func homeTimelineWithCompletion(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.GET(
            "1.1/statuses/home_timeline.json",
            parameters: params,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                //                        print("home_timeline: \(response!)")
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
            },
            failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting home timeline")
                print(error)
                completion(tweets: nil, error: error)
        })
    }
    
    func userTimelineWithCompletion(sinceID: String = "", completion: (tweets: [Tweet], error: NSError?) -> ()) {
        
        var parameters = NSMutableDictionary()
        parameters["screen_name"] = User.currentUser?.screenname
        
        TwitterClient.sharedInstance.GET("1.1/statuses/user_timeline.json",
            parameters: parameters,
            success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                //                        print("home_timeline: \(response!)")
                let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
                completion(tweets: tweets, error: nil)
            },
            failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error getting home timeline")
                print(error)
                completion(tweets: [Tweet](), error: error)
        })


    }
    
    
    func favoriteTweetWithCompletion(tweetID: String, completion: (error: NSError?) -> ()) {
        
        if _currentUser != nil {
            
            let parameters = NSMutableDictionary()
            parameters["id"] = tweetID
            
            TwitterClient.sharedInstance.POST("1.1/favorites/create.json", parameters: parameters, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                print("successfully favorited tweet")
                completion(error: nil)
                },
                failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                    print("error favoriting")
                    print(error)
                    completion(error: error)
                    // does not return anything else
            })
        }
    }
    
    func postTweetWithCompletion(status: String, completion: (error: NSError?) -> ()) {
        let parameters = NSMutableDictionary()
        parameters["status"] = status
        
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: parameters, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            print("posting status")
            completion(error: nil)
            },
            failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error posting status")
                print(error)
                completion(error: nil)
        })

    }

    
    func unFavoriteTweetWithCompletion(ID: String, completion: (response: NSDictionary?, error: NSError?) -> ()) {
        let parameters = NSMutableDictionary()
        parameters["id"] = ID
        
        TwitterClient.sharedInstance.POST("1.1/favorites/destroy.json", parameters: parameters, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
            print("unFavorited")
            completion(response: response as? NSDictionary, error: nil)
            },
            failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                print("error unFavoriting")
                print(error)
                completion(response: nil, error: error)
        })
    }
    
    func sendRetweetWithCompletion(tweetID: String, completion: (error: NSError?) -> ()) {
        
        if _currentUser != nil {
            
            TwitterClient.sharedInstance.POST("https://api.twitter.com/1.1/statuses/retweet/\(tweetID).json", parameters: nil, success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                print("successfully sent retweet")
                completion(error: nil)
                },
                failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                    print("error retweeting")
                    print(error)
                    completion(error: error)
                    // does not return anything else since it is a POST
            })
        }
    }
    
    func replyToTweet(content:String, id:String, completion:(success:Bool)->Void){
        let parameter = ["status":content,"in_reply_to_status_id":id]
        print(id)
        TwitterClient.sharedInstance.POST("1.1/statuses/update.json", parameters: parameter, success: { (task:NSURLSessionDataTask, response:AnyObject?) -> Void in
            print("replies succeed")
            completion(success: true)
            }) { (task:NSURLSessionDataTask?, error:NSError) -> Void in
                print("replies failed\(error)")
                completion(success: false)
        }
    }
    
    func sendUnRetweetWithCompletion(ID: String, completion: (response: NSDictionary?, error: NSError?) -> ()) {
        if _currentUser != nil {
            POST("https://api.twitter.com/1.1/statuses/unretweet/\(ID).json", parameters: nil, success: { (operation: NSURLSessionDataTask, response: AnyObject?) -> Void in
                completion(response: response as? NSDictionary, error: nil)
                print("unretweeted")
                }) { (operation: NSURLSessionDataTask?, error: NSError) -> Void in
                    completion(response: nil, error: error)
                    print("error unretweeting")
            }
        }
        
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        // Fetch request token & redirect
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        TwitterClient.sharedInstance.fetchRequestTokenWithPath(
            "oauth/request_token",
            method: "GET",
            callbackURL: NSURL(string: "cpttwitterdemo://oauth"),
            scope: nil,
            success: {
                (requestToken: BDBOAuth1Credential!) -> Void in
                print("Got the request token")
                
                let authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                
                UIApplication.sharedApplication().openURL(authURL!)
                
            }) {
                (error: NSError!) -> Void in
                print("Failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath(
            "oauth/access_token",
            method: "POST",
            requestToken: BDBOAuth1Credential(queryString: url.query),
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                print("Got the access token!")
                
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
                
                TwitterClient.sharedInstance.GET(
                    "1.1/account/verify_credentials.json",
                    parameters: nil,
                    success: { (operation: NSURLSessionDataTask!, response: AnyObject?) -> Void in
                        //                        print("user: \(response!)")
                        let user = User(dictionary: response as! NSDictionary)
                        
                        User.currentUser = user // set
                        print("user: \(user.name!)")
                        self.loginCompletion!(user: user, error:  nil)
                    },
                    failure: { (operation: NSURLSessionDataTask?, error: NSError!) -> Void in
                        print("error getting current user")
                        self.loginCompletion?(user: nil, error: error)
                })
            },
            failure: { (error: NSError!) -> Void in
                print("Failed to receive access token")
                self.loginCompletion?(user: nil, error: error)
        })
    }
}
