//
//  Cam.swift
//  CAM4
//
//  Created by ryan on 2015-11-09.
//  Copyright © 2015 Ryan Maule. All rights reserved.
//

import Foundation

class Cam {
    var title: String!
    var cam4Url: String!
    var thumbnail: String!
    
    init(camDict: Dictionary<String, AnyObject>) {
        if let title = camDict["username/_text"] as? String {
            self.title = title
        }
        if let cam4Url = camDict["username"] as? String {
            self.cam4Url = cam4Url
        }
        if let thumbnail = camDict["thumbnail"] as? String {
            self.thumbnail = thumbnail
        }
    }
}