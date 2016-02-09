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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
                    let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? Dictionary<String, AnyObject>
                    print(dict)
                }
                catch {
                    print("downloadData Error: dict Issue")
                }
            }
        }
        task.resume()
    }
    
}
