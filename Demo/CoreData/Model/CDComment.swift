//
//  CDComment.swift
//  Demo
//
//  Created by Genevieve Timms on 07/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import CoreData

class CDComment: NSManagedObject {
    
    func asComment() -> Comment {
        return Comment(id: id, postId: postId, name: name!, body: body!)
    }
    
    class func findOrCreate(from comments: [Comment], in context: NSManagedObjectContext) throws -> [CDComment] {
        
        var existingComments = [CDComment]()
        
        //Fetch existing comments
        let request: NSFetchRequest<CDComment> = CDComment.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", comments.map{$0.id})
        do {
            existingComments = try context.fetch(request)
        } catch {
            throw error
        }
        
        //Filter existing comments
        let newComments = comments.filter{!(existingComments.map{$0.id}.contains(Int32($0.id)))}
        
        //Add new comments
        for comment in newComments {
            let newComment = CDComment(context: context)
            newComment.id = comment.id
            newComment.postId = comment.postId
            newComment.name = comment.name
            newComment.body = comment.body
            existingComments.append(newComment)
        }
        return existingComments
    }
}
