//
//  CDCommentTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
@testable import Demo

class CDCommentTests: XCTestCase {
    
    var coreDataStack: CoreDataTestStack!
    var context: MockManagedObjectContext!
    
    let comments = [ModelStubs.comments[0],
                    ModelStubs.comments[1]]
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataTestStack()
        context = coreDataStack.backgroundContext
    }
    
    func insert(_ comments: [Comment]) throws -> [CDComment] {
        let savedComments = try CDComment.findOrCreate(from: comments, in: context)
        try context.save()
        return savedComments
    }
    
    func fetchComments() throws -> [CDComment] {
        let request: NSFetchRequest<CDComment> = CDComment.fetchRequest()
        let comments = try context.fetch(request)
        return comments
    }
    
    func test_findOrCreateComments_createsNewComments() {
        _ = try! insert(comments)
        let savedComments = try! fetchComments()
        
        XCTAssertEqual(savedComments.count, comments.count)
    }
    
    func test_findOrCreateComments_findsCurrentComments() {
        coreDataStack.createStubs()
        var insertedComments = try! insert(comments)
        let savedComments = try! fetchComments()
        
        insertedComments.sort{$0.id > $1.id}
        let sortedComments = comments.sorted{$0.id > $1.id}
        
        XCTAssertEqual(savedComments.count, ModelStubs.comments.count)
        XCTAssertEqual(insertedComments[0].id, sortedComments[0].id)
        XCTAssertEqual(insertedComments[1].id, sortedComments[1].id)
    }
    
    func test_asComment_createsCommentModel() {
        let comment = comments[0]
        _ = try! insert([comment])
        let savedComments = try! fetchComments()
        
        guard let savedComment = savedComments.first else {
            XCTFail("Comment Missing")
            return
        }
        
        let commentModel = savedComment.asComment()
        
        XCTAssertEqual(comment.id, commentModel.id)
        XCTAssertEqual(comment.name, commentModel.name)
    }
}
