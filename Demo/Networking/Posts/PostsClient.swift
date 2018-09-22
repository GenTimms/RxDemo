//
//  PostsClient.swift
//  Demo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class PostsClient: Client {
   
    var session: SessionProtocol = URLSession.shared
    
    func fetch(completion: @escaping (Result<[Post]>) -> Void) {
        var posts = [Post]()
        var comments = [Comment]()
        var users = [User]()
        
        var errors = [Error]()
        let group = DispatchGroup()
        
        group.enter()
        fetchPartialPosts { result in
            switch result {
            case .success(let fetchedPosts):  posts = fetchedPosts; group.leave()
            case .failure(let error): errors.append(error); group.leave();
            }
        }
        
        group.enter()
        fetchComments{ result in
            switch result {
            case .success(let fetchedComments): comments = fetchedComments; group.leave()
            case .failure(let error): errors.append(error); group.leave();
            }
        }
        
        group.enter()
        fetchUsers{ result in
            switch result {
            case .success(let fetchedUsers): users = fetchedUsers; group.leave()
            case .failure(let error): errors.append(error); group.leave();
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            guard errors.isEmpty else {
                completion(Result.failure(errors.first!))
                return
            }
            
            for post in posts {
                post.user = users.first{$0.id == post.userId}
                post.comments = comments.filter{$0.postId == post.id}
            }
            completion(Result.success(posts))
        }
    }

    func fetchPartialPosts(completion: @escaping (Result<[Post]>) -> Void) {
        guard let request = PostsEndpoints.posts.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetchRequest(request, parse: { (data) -> [Post]? in
            if let posts = Post.createPosts(from: data) {
                return posts
            } else {
                return nil
            }
        }, completion: completion)
    }
    
    func fetchComments(completion: @escaping (Result<[Comment]>) -> Void) {
        guard let request = PostsEndpoints.comments.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetchRequest(request, parse: { (data) -> [Comment]? in
            if let comments = Comment.createComments(from: data) {
                return comments
            } else {
                return nil
            }
        }, completion: completion)
    }
    
    func fetchUsers(completion: @escaping (Result<[User]>) -> Void) {
        guard let request = PostsEndpoints.users.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetchRequest(request, parse: { (data) -> [User]? in
            if let users = User.createUsers(from: data) {
                return users
            } else {
                return nil
            }
        }, completion: completion)
    }
}
