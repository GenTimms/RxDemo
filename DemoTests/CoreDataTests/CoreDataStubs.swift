//
//  CoreDataStubs.swift
//  BabylonDemoTests
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

struct CoreDataStubs {
    static let posts = [Post(id: 1, userId: 1, title: "Title", body: "Post Body", user: users[0], comments: [comments[0], comments[1]]),
                        Post(id: 2, userId: 2, title: "Title", body: "Post Body", user: users[1], comments: [comments[2], comments[3]]),
                        Post(id: 3, userId: 3, title: "Title", body: "Post Body", user: users[2], comments: [comments[4], comments[5]]),
                        Post(id: 4, userId: 4, title: "Title", body: "Post Body", user: users[3], comments: [comments[6], comments[7]])]
    
    static let comments: [Comment] = {
        var comments = [Comment]()
        for id in 1...8 {
            comments.append(Comment(id: Int32(id), postId: 1, name: "Name", body: "Comment Body"))
        }
        return comments
    }()
    
    static let users = [User(id: 1, name: "Genevieve Timms"),
                        User(id: 2, name: "Nick Pederson"),
                        User(id: 3, name: "Rui Peres"),
                        User(id: 4, name: "Ali Parsa")]
}
