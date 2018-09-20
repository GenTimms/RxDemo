//
//  PostDetailViewModel.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

struct PostDetailViewModel {
    let body: String
    let user: String
    let commentCount: String
}

extension PostDetailViewModel {
    init(post: Post) {
        body = post.body
        user = (post.user?.name ?? "Anonymous User")
        commentCount = "Comments: " + String(post.comments.count)
    }
}
