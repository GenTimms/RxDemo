//
//  PostStorageManagerTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
@testable import Demo

class PostStorageManagerTests: XCTestCase {
    
    var sut: PostStorageManager!
    var coreDataStack = CoreDataTestStack()
    
    var post = ModelStubs.posts.last!
    
    var viewContext: MockManagedObjectContext!
    var backgoundContext: MockManagedObjectContext!
    
    override func setUp() {
        viewContext = coreDataStack.mainContext
        backgoundContext = coreDataStack.backgroundContext
        
        sut = PostStorageManager(backgroundContext: backgoundContext, viewContext: viewContext)
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func fetchPosts() throws -> [CDPost] {
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        let posts = try viewContext.fetch(request)
        return posts
    }
    
    func testInsertPosts_InsertsPost() {
        let performAndWaitExpectation = expectation(description: "Perform and Wait")
        
        backgoundContext.expectation = performAndWaitExpectation
        
        sut.insert([post]) { error in
            XCTFail("Context Save Failed")
        }
        
        waitForExpectations(timeout: 1) { _ in
            let posts = try! self.fetchPosts()
            guard let savedPost = posts.first else {
                XCTFail("Post Missing")
                return
            }
            
            let fetchedPost = savedPost.asPost()
            XCTAssertEqual(fetchedPost.id, self.post.id)
        }
    }
    
    func testInsertPosts_ReturnsErrorWhenSaveFails() {
        let errorExpectation = expectation(description: "Save Error Expectation")
        var caughtError: Error? = nil
        
        backgoundContext.saveThrows = true
        
        sut.insert([post]) { error in
            caughtError = error
            errorExpectation.fulfill()
        }
        waitForExpectations(timeout: 1) { _ in
            XCTAssertNotNil(caughtError)
        }
    }
    
    func testCreateFetchedResultsController_ReturnsController() {
        let fetchedResultsController = sut.createFetchedResultsController()
        
        XCTAssertEqual(fetchedResultsController.fetchRequest.entityName, "Post")

    }
}
