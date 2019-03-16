//
//  PostStorageManagerTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
import RxSwift
import RxCocoa
import RxBlocking

@testable import Demo

class PostStorageManagerTests: XCTestCase {
    
    var sut: PostStorageManager!
    var coreDataStack: CoreDataTestStack!
    
    var post = ModelStubs.posts.last!
    
    var viewContext: MockManagedObjectContext!
    var backgoundContext: MockManagedObjectContext!
    
    override func setUp() {
        coreDataStack = CoreDataTestStack()
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
    
    //MARK: - Rx Tests
    func testRxInsert_InsertsPosts() {
        
        var caughtError: Error? = nil
        
        do {
            try sut.rxInsert([post]).asObservable().toBlocking(timeout: 3).single()
        } catch {
            caughtError = error
        }
        
        print("Error: \(caughtError)")
        let posts = try! self.fetchPosts()
        
        guard let savedPost = posts.first else {
            XCTFail("Post Missing")
            return
        }
        
        let fetchedPost = savedPost.asPost()
        print("Post: \(fetchedPost)")
        XCTAssertEqual(fetchedPost.id, self.post.id)
    }
    
    func testRxInsert_ReturnsErrorWhenSaveThrows() {
        
        var caughtError: Error? = nil
        
        backgoundContext.saveThrows = true
        do {
            try sut.rxInsert([post]).asObservable().toBlocking(timeout: 3).single()
        } catch {
            caughtError = error
        }
        
        print("Error: \(caughtError)")
        let posts = try! self.fetchPosts()
        
        XCTAssertNotNil(caughtError)
        XCTAssertNil(posts.first)
    }
    
    func testFetch_ReturnsStoredPosts() {
        coreDataStack.createStubs()
        var caughtError: Error?
        var posts: [Post]?
        
        do {
            try posts = sut.fetch().asObservable().toBlocking().single()
        } catch {
            caughtError = error
        }
        
        XCTAssertNil(caughtError)
        XCTAssertEqual(posts?.count, ModelStubs.posts.count)
    }
    
    func testFetch_ReturnsErrorWhenFetchThrows() {
        coreDataStack.createStubs()
        var caughtError: Error?
        var posts: [Post]?
        
        viewContext.fetchThrows = true
        
        do {
            try posts = sut.fetch().asObservable().toBlocking().single()
        } catch {
            caughtError = error
        }
        print("Error: \(caughtError)")
        XCTAssertNotNil(caughtError)
        XCTAssertNil(posts)
    }
    
    func testConvenienceInit_InitialisesContextFromAppDelegat() {
        let storageManager = PostStorageManager()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let viewContext = appDelegate?.persistentContainer.viewContext
        XCTAssertNotNil(storageManager.backgroundContext)
        XCTAssertEqual(storageManager.viewContext, viewContext)
    }
}
