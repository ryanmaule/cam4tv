//
//  ViewController.swift
//  CAM4
//
//  Created by ryan on 2015-11-08.
//  Copyright © 2015 Ryan Maule. All rights reserved.
//

/*
To Do:
- Connect CAM4 header
- Standardize thumbnail sizes
- Add categories for Female, Male, Trans, Couple, New
*/

import UIKit
import AVKit
import AVFoundation
import CoreLocation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var localCollectionView: UICollectionView!
    
    var locationManager = CLLocationManager()
    var currentLocation : CLPlacemark?
    var detectLocation : CLLocationManager?
    
    var locality = ""
    var postalCode = ""
    
    let defaultSize = CGSizeMake(328, 278)
    let focusSize = CGSizeMake(328+16, 278+14)
    let itemSize = CGSizeMake(372, 369)
    
    var trendingCams = [Cam]()
    var localCams = [Cam]()
    
    let URL_BASE_TRENDING = "https://api.import.io/store/data/e9c58785-d16f-4061-89a7-1833b940cf0e/_query?input/webpage/url=http%3A%2F%2Fwww.cam4.com%2F&_user=009709b7-5e61-4d47-99af-1403f3acaa88&_apikey=009709b75e614d4799af1403f3acaa884dbbb1c097366f504221fdb3c73b69057368743e61de127ae810cd55c2f92ee0cbd27125a9af044d43323c8f65a6c286f8674935dc940ab67af26c711fc9bbe3"
    
    let URL_BASE_LOCAL = "https://api.import.io/store/data/e9c58785-d16f-4061-89a7-1833b940cf0e/_query?input/webpage/url=http%3A%2F%2Fwww.cam4.com%2Fcanada-cams&_user=009709b7-5e61-4d47-99af-1403f3acaa88&_apikey=009709b75e614d4799af1403f3acaa884dbbb1c097366f504221fdb3c73b69057368743e61de127ae810cd55c2f92ee0cbd27125a9af044d43323c8f65a6c286f8674935dc940ab67af26c711fc9bbe3"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Show Setup
        setupApp()
        
        //self.getLocation()
        
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        
        localCollectionView.delegate = self
        localCollectionView.dataSource = self
        
        // Set timer to refresh data
        self.update()
        NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "update", userInfo: nil, repeats: true)
    }
    
    func setupApp() {
        if let authController = storyboard!.instantiateViewControllerWithIdentifier("AuthViewController") as? AuthViewController {
            presentViewController(authController, animated: true, completion: nil)
        }
    }
    
    func getLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.locationServicesEnabled() {
            
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            else if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
                locationManager.requestLocation()
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil)
            {
                print("Error: " + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0
            {
                let pm = placemarks![0]
                self.displayLocationInfo(pm)
            }
            else
            {
                print("Error with the location data.")
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        self.locationManager.stopUpdatingLocation()
        print(placemark.locality)
        print(placemark.postalCode)
        print(placemark.administrativeArea)
        print(placemark.country)
    }
    
    func update() {
        // Reload content arrays for each collection
        downloadData(URL_BASE_TRENDING, collectionView: trendingCollectionView)
        downloadData(URL_BASE_LOCAL, collectionView: localCollectionView)
    }
    
    func downloadData(input_url: String, collectionView: UICollectionView) {
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
                    
                    // Ensure array is empty
                    // There should be a better way to do this.. need to load the proper array for each collection
                    if collectionView==self.trendingCollectionView {
                        self.trendingCams.removeAll()
                    } else {
                        self.localCams.removeAll()
                    }
                    
                    if let results = dict!["results"] as? [Dictionary<String, AnyObject>] {
                        for obj in results {
                            let cam = Cam(camDict: obj)
                            // There should be a better way to do this.. need to load the proper array for each collection
                            if collectionView==self.trendingCollectionView {
                                self.trendingCams.append(cam)
                            } else {
                                self.localCams.append(cam)
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            collectionView.reloadData()
                        }
                    }
                }
                catch {
                    print("downloadData Error: dict Issue")
                }
            }
        }
        task.resume()
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CamCell", forIndexPath: indexPath) as? CamCell {
            var cam: Cam
            // There should be a better way to do this.. need to load the proper array for each collection
            if collectionView==trendingCollectionView {
                cam = trendingCams[indexPath.row]
            } else {
                cam = localCams[indexPath.row]
            }
            
            cell.configureCell(cam)
            
            if cell.gestureRecognizers?.count == nil {
                let tap = UITapGestureRecognizer(target: self, action: "tapped:")
                tap.allowedPressTypes = [NSNumber(integer: UIPressType.Select.rawValue)]
                cell.addGestureRecognizer(tap)
            }
            return cell
        }
        else {
            return CamCell()
        }
    }
    
    func tapped(gesture: UITapGestureRecognizer) {
        if let cell = gesture.view as? CamCell {
            // Change view controllers and execute setupCam(username) in the new controller
            performSegueWithIdentifier("ShowVideo", sender: cell.camLabel.text!)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "ShowVideo") {
            let secondViewController = segue.destinationViewController as! PlayerViewController
            let username = sender as! String
            secondViewController.username = username
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var cams = [Cam]()
        if collectionView==self.trendingCollectionView {
            cams = self.trendingCams
        } else {
            cams = self.localCams
        }
        
        return cams.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return itemSize
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if let prev = context.previouslyFocusedView as? CamCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                prev.camImg.frame.size = self.defaultSize
            })
        }
        
        if let next = context.nextFocusedView as? CamCell {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                next.camImg.frame.size = self.focusSize
            })
        }
    }

}

