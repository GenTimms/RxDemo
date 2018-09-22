//
//  CodablePost.swift
//  Demo
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

extension Post {
    
   enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case body
    }
    
    static func createPosts(from json: Data) -> [Post]? {
        if let posts = try? JSONDecoder().decode([Post].self, from: json) {
            return posts
        } else {
            return nil
        }
    }
    
    static func createJSON(from comments: [Post]) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(comments)
    }
}
