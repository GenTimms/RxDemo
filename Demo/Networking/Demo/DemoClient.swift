//
//  DemoClient.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class DemoClient: Client {
    
    var session: SessionProtocol = URLSession.shared
    
    var postFetchingError: Error?
    var commentFetchingError: Error?
    var userFetchingError: Error?
    
    var posts = [Post]()
    var comments = [Comment]()
    var users = [User]()
    
    func fetchPosts(completion: @escaping (Result<[Post]>) -> Void) {
        
        let queue = OperationQueue()
        let operations = [PostsOperation(client: self), UsersOperation(client: self), CommentsOperation(client: self)]
        
        DispatchQueue.global(qos: .userInitiated).async {
            queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async { [weak self] in
                if let error = self?.postFetchingError  {
                    completion(Result.failure(error))
                    return
                }
                if let error = self?.commentFetchingError  {
                    completion(Result.failure(error))
                    return
                }
                if let error = self?.userFetchingError  {
                    completion(Result.failure(error))
                    return
                }
                self?.completePosts()
                if let client = self {
                    completion(Result.success(client.posts))
                }
            }
        }
    }
    
    private func completePosts() {
        for post in posts {
            post.user = users.first{$0.id == post.userId}
            post.comments = comments.filter{$0.postId == post.id}
        }
    }
    
    func fetchPartialPosts(completion: @escaping (Result<[Post]>) -> Void) {
        guard let request = Demo.posts.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetch(with: request, parse: { (data) -> [Post]? in
            if let posts = Post.createPosts(from: data) {
                return posts
            } else {
                return nil
            }
        }, completion: completion)
    }
    
    func fetchComments(completion: @escaping (Result<[Comment]>) -> Void) {
        guard let request = Demo.comments.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetch(with: request, parse: { (data) -> [Comment]? in
            if let comments = Comment.createComments(from: data) {
                return comments
            } else {
                return nil
            }
        }, completion: completion)
    }
    
    func fetchUsers(completion: @escaping (Result<[User]>) -> Void) {
        guard let request = Demo.users.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetch(with: request, parse: { (data) -> [User]? in
            if let users = User.createUsers(from: data) {
                return users
            } else {
                return nil
            }
        }, completion: completion)
    }
}
