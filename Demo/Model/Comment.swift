//
//  Comment.swift
//   Demo
//
//  Created by Genevieve Timms on 07/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class Comment: Codable  {
    
    let id: Int32
    let postId: Int32
    let name: String
    let body: String
    
    init(id: Int32, postId: Int32, name: String, body: String) {
        self.id = id
        self.postId = postId
        self.name = name
        self.body = body
    }
}
