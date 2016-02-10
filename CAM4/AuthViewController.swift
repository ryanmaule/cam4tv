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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 1. Check for authorization before running downloadData
        // poll()
        downloadData(URL_GENERATE_AUTH_CODE)
    }
    
    func downloadData(input_url: String) {
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
                    let auth_code = results!["auth_code"] as! String?
                    
                    // 2. This can't go here
                    dispatch_async(dispatch_get_main_queue()) {
                        self.AuthCodeLabel.text = auth_code
                        
                        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "poll", userInfo: nil, repeats: true)
                        
                        // 3. When authorized, load the main view
                        
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
        downloadData(URL_POLL_AUTH_CODE)
    }
    
}
