//
//  Post.swift
//  Demo
//
//  Created by Genevieve Timms on 07/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class Post: Codable {
    
    let id: Int32
    let userId: Int32
    let title: String
    let body: String
    var user: User?
    var comments = [Comment]()
    
    init(id: Int32, userId: Int32, title: String, body: String, user: User?, comments: [Comment]?) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.user = user
        self.comments = comments ?? [Comment]()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case body
    }
}     

