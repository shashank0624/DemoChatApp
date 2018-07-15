//
//  File.swift
//  DemoChatApp
//
//  Created by Kirti Ahlawat on 10/05/18.
//  Copyright © 2018 Shashank Panwar. All rights reserved.
//

import UIKit
import Firebase

class Message : NSObject{
    var fromId : String?
    var text : String?
    var timeStamp : Int?
    var toId : String?
    var imageUrl : String?
    var imageHeight : NSNumber?
    var imageWidth: NSNumber?
    
    var videoUrl : String?
    
    func chatPartnerId() -> String?{
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dict: [String:Any]){
        super.init()
        fromId = dict["fromId"] as? String
        text = dict["text"] as? String
        toId = dict["toId"] as? String
        imageUrl = dict["imageUrl"] as? String
        timeStamp = dict["timestamp"] as? Int
        imageHeight = dict["imageHeight"] as? NSNumber
        imageWidth = dict["imageWidth"] as? NSNumber
        videoUrl = dict["videoUrl"] as? String
    }
}
