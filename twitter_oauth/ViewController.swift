//
//  ViewController.swift
//  twitter_oauth
//
//  Created by Rohan Y. Shah on 7/1/16.
//  Copyright © 2016 Rohan Y. Shah. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {
    
    @IBAction func onLogin(sender: AnyObject) { // login button
        // can put this in User
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, error: NSError?) in
            if user != nil {
                // perform segue
                self.performSegueWithIdentifier("loginSegue", sender: self)
            } else {
                // handle error
            }
        }
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

