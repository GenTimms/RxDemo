//
//  Endpoints.swift
//  Demo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

enum PostsEndpoints {
    case posts
    case comments
    case users
}

extension PostsEndpoints: Endpoint {
    var base: String {
        return "http://jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .posts: return "/posts"
        case .comments: return "/comments"
        case .users: return "/users"
        }
    }
}
