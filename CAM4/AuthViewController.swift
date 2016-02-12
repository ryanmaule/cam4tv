//
//  AuthViewController.swift
//  CAM4
//
//  Created by ryan on 2016-01-01.
//  Copyright © 2016 Ryan Maule. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class AuthViewController: UIViewController {
    
    let URL_GENERATE_AUTH_CODE = "http://dylan.ryanmaule.com/cam4tv/api/devices/generate.php"
    let URL_POLL_AUTH_CODE = "http://dylan.ryanmaule.com/cam4tv/api/devices/poll.php"
    
    @IBOutlet weak var AuthCodeLabel: UILabel!
    
    var auth_code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Check for authorization in case it's already done
        self.poll()
        // Generate an auth code
        self.downloadData(URL_GENERATE_AUTH_CODE, callback:{ (results)->Void in
            self.auth_code = (results["auth_code"] as! String?)!
            
            // Respond by setting the auth code and initiating polling loop
            self.AuthCodeLabel.text = self.auth_code
            NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "poll", userInfo: nil, repeats: true)
        })
    }
    
    func downloadData(input_url: String, callback: (Dictionary<String, AnyObject>)->()) {
        let url = NSURL(string: input_url)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) ->
            Void in
            
            if error != nil {
                print("downloadData Error: " + error.debugDescription)
            }
            else {
                do {
                    let results = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? Dictionary<String, AnyObject>
                    // Execute callback
                    dispatch_async(dispatch_get_main_queue()) {
                        print(results)
                        callback(results!)
                    }
                }
                catch {
                    print("downloadData Error: dict Issue")
                }
            }
        }
        task.resume()
    }
    
    func poll() {
        let poll_url = URL_POLL_AUTH_CODE+"?auth_code="+self.auth_code
        print(poll_url)
        // Check if auth code is authorized
        downloadData(poll_url, callback:{ (results)->Void in
            if (results["success"] != nil) {
                let success = results["success"] as! Bool
                if success {
                    print("Success")
                    // Display the Main View Controller
                    if let mainViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainViewController") as? MainViewController {
                        self.presentViewController(mainViewController, animated: true, completion: nil)
                    }
                }
                else {
                    print("Not Authorized")
                }
            }
            else {
                print("API Error")
            }
        })
    }
    
}
