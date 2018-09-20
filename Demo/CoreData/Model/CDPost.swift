///Users/Genni/Documents/Developer/My Apps/BabylonDemo/BabylonDemo/CoreData/Model/CDPost.swift
//  CDPost.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 07/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import CoreData

class CDPost: NSManagedObject {
    
    func asPost() -> Post {
        let modelComments = comments!.map{($0 as! CDComment).asComment()}
        let modelUser = user!.asUser()
        
        return Post(id: id, userId: userId, title: title!, body: body!, user: modelUser, comments: modelComments)
    }
    
    class func findOrCreate(from posts: [Post], in context: NSManagedObjectContext) throws -> [CDPost] {
        
        var existingPosts = [CDPost]()
        
        //Fetch existing posts
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", posts.map{$0.id})
        do {
            existingPosts = try context.fetch(request)
        } catch {
            throw error
        }
        
        //Filter existing posts
        let newPosts = posts.filter{!(existingPosts.map{$0.id}.contains(Int32($0.id)))}
        
        //Create new posts
        for post in newPosts {
            let newPost = CDPost(context: context)
            newPost.id = post.id
            newPost.userId = post.userId
            newPost.title = post.title
            newPost.body = post.body
            if let user = post.user {
                newPost.user = try? CDUser.findOrCreate(from: user, in: context)
            }
            if let comments = try? CDComment.findOrCreate(from: post.comments, in: context) {
                newPost.addToComments(NSSet(array: comments))
            }
            existingPosts.append(newPost)
        }
         return existingPosts
    }
}
