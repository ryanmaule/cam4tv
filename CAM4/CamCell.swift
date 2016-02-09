//
//  CamCell.swift
//  CAM4
//
//  Created by ryan on 2015-11-08.
//  Copyright © 2015 Ryan Maule. All rights reserved.
//

import UIKit

class CamCell: UICollectionViewCell {
    @IBOutlet weak var camImg: UIImageView!
    @IBOutlet weak var camLabel: UILabel!
    
    func configureCell(cam: Cam) {
        if let title = cam.title {
            self.camLabel.text = title
        }
        if let thumbnail = cam.thumbnail {
            let url = NSURL(string: thumbnail)!
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url)!
                
                dispatch_async(dispatch_get_main_queue()) {
                    let img = UIImage(data: data)
                    self.camImg.image = img
                }
            }
        }
    }
    
}
