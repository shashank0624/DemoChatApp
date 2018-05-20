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
    
    
    func chatPartnerId() -> String?{
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
