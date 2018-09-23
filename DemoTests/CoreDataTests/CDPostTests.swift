//
//  CDPostTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
@testable import Demo

class CDPostTests: XCTestCase {
    
    var coreDataStack: CoreDataTestStack!
    var context: MockManagedObjectContext!
    
    let posts = [CoreDataStubs.posts[0], CoreDataStubs.posts[1]]
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataTestStack()
        context = coreDataStack.backgroundContext
    }
    
    func insert(_ posts: [Post]) throws -> [CDPost] {
        let savedPosts = try CDPost.findOrCreate(from: posts, in: context)
        try context.save()
        return savedPosts
    }
    
    func fetchPosts() throws -> [CDPost] {
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        let posts = try context.fetch(request)
        return posts
    }
    
    func fetchUsers() throws -> [CDUser] {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        let users = try context.fetch(request)
        return users
    }
    
    func fetchComments() throws -> [CDComment] {
        let request: NSFetchRequest<CDComment> = CDComment.fetchRequest()
        let comments = try context.fetch(request)
        return comments
    }
    
    func test_findOrCreatePosts_createsNewPosts() {
        _ = try! insert(posts)
        var savedPosts = try! fetchPosts()
        
        savedPosts.sort{$0.id > $1.id}
        let sortedPosts = posts.sorted{$0.id > $1.id}
        
        XCTAssertEqual(savedPosts.count, posts.count)
        XCTAssertEqual(savedPosts[0].id, Int32(sortedPosts[0].id))
        XCTAssertEqual(savedPosts[1].id, Int32(sortedPosts[1].id))
    }
    
    func test_findOrCreatePosts_findsCurrentPosts() {
        coreDataStack.createStubs()
        var insertedPosts = try! insert(posts)
        let savedPosts = try! fetchPosts()
        
        insertedPosts.sort{$0.id > $1.id}
        let sortedPosts = posts.sorted{$0.id > $1.id}
        
        XCTAssertEqual(savedPosts.count, CoreDataStubs.posts.count)
        XCTAssertEqual(insertedPosts[0].id, sortedPosts[0].id)
        XCTAssertEqual(insertedPosts[1].id, sortedPosts[1].id)
    }
    
    func test_findOrCreatePosts_createsUser() {
        _ = try! insert([posts[0]])
        let savedPosts = try! fetchPosts()
        let savedUsers = try! fetchUsers()
        
        XCTAssertEqual(savedUsers.count, 1)
        XCTAssertEqual(savedPosts.count, 1)
        XCTAssertEqual(savedPosts[0].user, savedUsers[0])
    }
    
    func test_findOrCreatePosts_createsComments() {
        _ = try! insert([posts[0]])
        let savedPosts = try! fetchPosts()
        let savedComments = try! fetchComments()
        
        XCTAssertEqual(savedComments.count, posts[0].comments.count)
        XCTAssertEqual(savedPosts.count, 1)
        XCTAssertEqual(NSSet(array: savedComments), savedPosts[0].comments)
    }
    
    func test_asPost_createsPostModel() {
        let post = posts[0]
        _ = try! insert([post])
        let savedPosts = try! fetchPosts()
        
        guard let savedPost = savedPosts.first else {
            XCTFail("Post Missing")
            return
        }
        
        let postModel = savedPost.asPost()
        
        XCTAssertEqual(post.id, postModel.id)
        XCTAssertEqual(post.title, postModel.title)
        XCTAssertEqual(post.body, postModel.body)
        XCTAssertEqual(post.comments.count, postModel.comments.count)
        XCTAssertEqual(post.user?.id, postModel.user?.id)
    }
}
