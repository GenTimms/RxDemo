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
    
    var posts = [Post]()
    var comments = [Comment]()
    var users = [User]()
    
    var errors = [Error]()
    let postsGroup =  DispatchGroup()
    
    var commentsClient = CommentsClient()
    var usersClient = UsersClient()
    
    func fetch(group: DispatchGroup? = nil, completion: @escaping (Result<[Post]>) -> Void) {
        group?.enter()
        
        fetchPostComponents()
        
        postsGroup.notify(queue: DispatchQueue.main) {
            guard self.errors.isEmpty else {
                completion(Result.failure(self.errors.first!))
                group?.leave()
                return
            }
            
            self.completePosts()
            completion(Result.success(self.posts))
            group?.leave()
        }
    }
    
    private func completePosts() {
        for post in posts {
            post.user = users.first{$0.id == post.userId}
            post.comments = comments.filter{$0.postId == post.id}
        }
    }
    
    private func fetchPostComponents() {
        fetchUsers()
        fetchComments()
        fetchPosts()
    }
    
    private func fetchUsers() {
        usersClient.fetch(group: postsGroup){ result in
            switch result {
            case .success(let fetchedUsers): self.users = fetchedUsers;
            case .failure(let error): self.errors.append(error);
            }
        }
    }
    
    private func fetchComments() {
        commentsClient.fetch(group: postsGroup){ result in
            switch result {
            case .success(let fetchedComments): self.comments = fetchedComments;
            case .failure(let error): self.errors.append(error);
            }
        }
    }
    
    private func fetchPosts() {
        fetchPartialPosts(group: postsGroup) { result in
            switch result {
            case .success(let fetchedPosts):  self.posts = fetchedPosts;
            case .failure(let error): self.errors.append(error);
            }
        }
    }
    
    private func fetchPartialPosts(group: DispatchGroup?, completion: @escaping (Result<[Post]>) -> Void) {
        group?.enter()
        guard let request = PostsEndpoints.posts.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetchRequest(request, parse: { (data) throws -> [Post] in
            return try data.createArray(ofType: Post.self)
        }, completion: { result in
            completion(result)
            group?.leave()
        })
    }
}
