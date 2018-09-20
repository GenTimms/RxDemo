//
//  CDUserTests.swift
//  BabylonDemoTests
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
@testable import Demo

class CDUserTests: XCTestCase {
    
    var coreDataStack: CoreDataTestStack!
    var context: MockManagedObjectContext!
    
    let user = CoreDataStubs.users[0]
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataTestStack()
        context = coreDataStack.backgroundContext
       
    }
    
    func insert(_ user: User) throws -> CDUser {
        let savedUser = try CDUser.findOrCreate(from: user, in: context)
        try context.save()
        return savedUser
    }
    
    func fetchUsers() throws -> [CDUser] {
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        let users = try context.fetch(request)
        return users
    }
    
    func test_findOrCreateUser_createsNewUser() {
        _ = try! insert(user)
        let savedUsers = try! fetchUsers()
        
        guard let savedUser = savedUsers.first else {
            XCTFail("User Missing")
            return
        }
        
        XCTAssertEqual(savedUsers.count, 1)
        XCTAssertEqual(savedUser.id, user.id)
    }
    
    func test_findOrCreateUser_findsCurrentUser() {
        coreDataStack.createStubs()
        let savedUser = try! insert(user)
        let savedUsers = try! fetchUsers()
        
        XCTAssertEqual(savedUsers.count, CoreDataStubs.users.count)
        XCTAssertEqual(savedUser.id, user.id)
    }
    
    func test_findOrCreateUser_throwsError_forDuplicateUsers() {
        coreDataStack.createStubs()
        coreDataStack.createStubs()
        
        var databaseError: CoreDataError? = nil
        
        do {
            try _ = insert(user)
        } catch {
            databaseError = error as? CoreDataError
        }
        
       XCTAssertEqual(databaseError, CoreDataError.databaseInconsistency)
    }
    
    func test_asUser_createsUserModel() {
        _ = try! insert(user)
        let savedUsers = try! fetchUsers()
        
        guard let savedUser = savedUsers.first else {
            XCTFail("User Missing")
            return
        }
        
        let userModel = savedUser.asUser()
        
        XCTAssertEqual(user.id, userModel.id)
        XCTAssertEqual(user.name, userModel.name)
    }
}
