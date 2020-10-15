//
//  Room.swift
//  CodezillaChatX
//
//  Created by Osama on 12/20/18.
//  Copyright © 2018 Osama Gamal. All rights reserved.
//

import UIKit

struct Room {
    var roomId:String?
    var name:String?
    var ownerId:String?
    
    

    init(array: [String: Any]){
        if let roomName = array["name"] as? String, let ownerIdx = array["creatorId"] as? String{
            self.name = roomName
            self.ownerId = ownerIdx
        }
    }
}
