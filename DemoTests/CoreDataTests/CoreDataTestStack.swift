//
//  CoreDataTestStack.swift
//  BabylonDemoTests
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
@testable import Demo

class CoreDataTestStack {
    lazy var managedObjectModel: NSManagedObjectModel = {
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle(for: type(of: self))] )!
        return managedObjectModel
    }()
    
    lazy var mockPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BabylonDemo", managedObjectModel: self.managedObjectModel)
        let description = container.persistentStoreDescriptions.first
        description?.type = NSInMemoryStoreType
        description?.shouldAddStoreAsynchronously = false
        
        container.loadPersistentStores { description, error in
            precondition(description.type == NSInMemoryStoreType)
            
            guard error == nil else {
                fatalError("unable to load store \(error!)")
            }
        }
        return container
    }()
    
    lazy var mainContext: MockManagedObjectContext = {
        let context = MockManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.automaticallyMergesChangesFromParent = true
        context.persistentStoreCoordinator = mockPersistentContainer.persistentStoreCoordinator
        return context
    }()
    
    lazy var backgroundContext: MockManagedObjectContext = {
        let context = MockManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.parent = self.mainContext
        return context
    }()
}

class MockManagedObjectContext: NSManagedObjectContext {
    var expectation: XCTestExpectation?
    
    var saveWasCalled = false
    
    override func performAndWait(_ block: () -> Void) {
        super.performAndWait(block)
        expectation?.fulfill()
    }
    
    override func save() throws {
        try super.save()
        saveWasCalled = true
    }
}

extension CoreDataTestStack {
    func createStubs() {
        func insertUser(_ user: User) -> CDUser {
            let userObject = NSEntityDescription.insertNewObject(forEntityName: "User", into: mockPersistentContainer.viewContext)
            
            userObject.setValue(user.id, forKey: "id")
            userObject.setValue(user.name, forKey: "name")
            
            return userObject as! CDUser
        }
        
        func insertComments(_ comments: [Comment]) -> [NSManagedObject] {
            
            var commentObjects = [NSManagedObject]()
            
            for comment in comments {
                let commentObject = NSEntityDescription.insertNewObject(forEntityName: "Comment", into: mockPersistentContainer.viewContext)
                
                commentObject.setValue(comment.id, forKey: "id")
                commentObject.setValue(comment.name, forKey: "name")
                commentObject.setValue(comment.body, forKey: "body")
                commentObjects.append(commentObject)
            }
            return commentObjects
        }
        
        func insertPosts(_ posts: [Post]) -> [NSManagedObject] {
            
            var postObjects = [NSManagedObject]()
            
            for post in posts {
            let postObject = NSEntityDescription.insertNewObject(forEntityName: "Post", into: mockPersistentContainer.viewContext)
            
            postObject.setValue(post.id, forKey: "id")
            postObject.setValue(post.title, forKey: "title")
            postObject.setValue(post.body, forKey: "body")
            postObject.setValue(insertUser(post.user!), forKey: "user")
            postObject.setValue(NSSet(array: insertComments(post.comments)), forKey: "Comments")
            postObjects.append(postObject)
            }
            return postObjects
        }
        
        _ = insertPosts(CoreDataStubs.posts)

        do {
            try mockPersistentContainer.viewContext.save()
        } catch {
            print("createStubs Error: \(error)")
        }
    }
}

