//
//  PlayerViewController.swift
//  CAM4
//
//  Created by ryan on 2016-01-01.
//  Copyright © 2016 Ryan Maule. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Firebase

class PlayerViewController: UIViewController {

    var username = "username"
    let pubnub_url = "http://dylan.ryanmaule.com/cam4tv/api/devices/session.php"
    let firebase_url = "http://dylan.ryanmaule.com/cam4tv/api/chat/cam4.php?room="

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCam(self.username)
        
        /*
        downloadFirebaseConfig(firebase_url+self.username, callback: { (results)->Void in
                let firebase_stream_url = (results["url"] as! String?)!
                self.streamChat(firebase_stream_url)
            }
        )
        */

        downloadData(self.pubnub_url+"?current_view="+self.username+"&auth_code="+auth_code)
    }
    
    func setupCam(username: String) {
        let HLS_URL = "https://api.import.io/store/connector/43e327d2-6b19-4dd6-a651-7eab372a6679/_query?input=webpage/url:http%3A%2F%2Fwww.cam4.com%2F" + username + "%2Fhls&&_apikey=009709b75e614d4799af1403f3acaa884dbbb1c097366f504221fdb3c73b69057368743e61de127ae810cd55c2f92ee0cbd27125a9af044d43323c8f65a6c286f8674935dc940ab67af26c711fc9bbe3"
        
        let url = NSURL(string: HLS_URL)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) ->
            Void in
            
            if error != nil {
                print("setupCam Error: " + error.debugDescription)
            }
            else {
                do {
                    let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? Dictionary<String, AnyObject>
                    
                    if let results = dict!["results"] as? [Dictionary<String, AnyObject>] {
                        for obj in results {
                            // Look for flashvars param and parse out the rtmp url
                            if let flashvars = obj["flashvars"] as? String {
                                // Use rexep to extract stream key
                                do {
                                    let regex = try NSRegularExpression(pattern: "videoPlayUrl=.+?\(self.username)-(.+?)(?=&)", options: [.CaseInsensitive])
                                    let match: NSTextCheckingResult? = regex.firstMatchInString(flashvars, options:[], range: NSMakeRange(0, flashvars.characters.count))
                                    if match != nil {
                                        let nsRange = match?.rangeAtIndex(1)
                                        let range = Range(start: flashvars.startIndex.advancedBy(nsRange!.location),
                                            end: flashvars.startIndex.advancedBy(nsRange!.location+nsRange!.length))
                                        let stream_key = flashvars.substringWithRange(range)
                                        
                                        // Concatenate path.
                                        // For now server is hard coded because we can't pretend to be on mobile in import.io
                                        let path = "http" + "://199.59.88.10:1935/cam4-edge-live/\(self.username.lowercaseString)-\(stream_key)" + "_aac/playlist.m3u8"
                                        
                                        // Must be done to prevent error
                                        dispatch_async(dispatch_get_main_queue(), {
                                            self.playCam(path)
                                        })
                                    }
                                    else {
                                        print("setupCam Error: RegEx Error")
                                    }
                                } catch let error as NSError {
                                    print("setupCam Error: " + error.localizedDescription)
                                }
                            }
                        }
                    }
                }
                catch {
                    print("setupCam Error: Can't parse JSON")
                }
            }
        }
        
        task.resume()
    }
    
    func playCam(cam_path: String) {
        // Play the video
        let PLAYER_URL = NSURL(string:cam_path)
        
        let player = AVPlayer(URL: PLAYER_URL!)
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        self.addChildViewController(playerController)
        self.view.addSubview(playerController.view)
        playerController.view.frame = self.view.frame
        
        // Add a CAM4 watermark
        let overlayView = UIView(frame: CGRectMake(250, 0, 100, 60))
        overlayView.addSubview(UIImageView(image: UIImage(named: "watermark")))
        self.view.addSubview(overlayView)
        
        player.play()
    }
    
    func downloadData(input_url: String) {
        let url = NSURL(string: input_url)!
        let request = NSURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        
        print(input_url)
        
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
                    }
                }
                catch {
                    print("downloadData Error: dict Issue")
                }
            }
        }
        task.resume()
    }
    
    func downloadFirebaseConfig(input_url: String, callback: (Dictionary<String, AnyObject>)->()) {
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
    
    func streamChat(firebase_url: String) {
        // Get a reference to our posts
        print(firebase_url)
        let ref = Firebase(url: firebase_url)
        //let handle = ref.observeAuthEventWithBlock({ authData in })
        
        // Attach a closure to read the data at our posts reference
        ref.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            }, withCancelBlock: { error in
                print(error.description)
        })
        //ref.removeAuthEventObserverWithHandle(handle)
    }
    
}
