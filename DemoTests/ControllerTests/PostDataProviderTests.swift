//
//  PostDataProviderTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 21/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
@testable import Demo

class PostDataProviderTests: XCTestCase {
    
    var postStorageManger: PostStorageManager!
    var sut: PostDataProvider!
    
    var coreDataStack: CoreDataTestStack!
    
    override func setUp() {
        coreDataStack = CoreDataTestStack()
        postStorageManger = PostStorageManager(backgroundContext: coreDataStack.backgroundContext, viewContext: coreDataStack.mainContext)
        sut = PostDataProvider(storageManager: postStorageManger)
        coreDataStack.createStubs()
    }
    
    func testObjectAtIndexPath_FetchesObject() {
        sut.fetchData { _ in }
        let post = sut.objectAt(indexPath: IndexPath(row: 0, section: 0))
        XCTAssertEqual(post.id, ModelStubs.posts[0].id)
    }
    
    func testFetchData_PerformsFetch() {
        sut.fetchData {_ in }
        XCTAssertEqual(ModelStubs.posts.count, sut.fetchedResultsController.fetchedObjects?.count)
    }
    
    func testFailedFetch_CallsCompletionWithError() {
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        sut.fetchedResultsController = MockFetchedResultsController(fetchRequest: request, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        sut.fetchData { error in
            XCTAssertNotNil(error)
        }
    }
}

extension PostDataProviderTests {
    
    class MockFetchedResultsController: NSFetchedResultsController<CDPost> {
        override func performFetch() throws {
            throw ClientData.error
        }
    }
}
