//
//  UsersClientTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 03/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class UsersClientTests: XCTestCase {
    
    var usersClient: UsersClient!
    var mockURLSession: MockURLSession!
    
    let userGroup = DispatchGroup()
        let response =  HTTPURLResponse(url: URL(string: "http://jsonplaceholder.typicode.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    
    let userData: Data! = {
        if let path = Bundle.main.path(forResource: "users", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    override func setUp() {
        super.setUp()
        usersClient = UsersClient()
        mockURLSession = MockURLSession(data: userData, urlResponse: response, error: nil)
        usersClient.session = mockURLSession
    }
    
    func testFetch_ReturnsUsers() {
        let userExpectatation = expectation(description: "UserFetch")
        var users = [User]()
        usersClient.fetch { result in
            switch result {
            case .success(let fetchedUsers): users = fetchedUsers; userExpectatation.fulfill()
            case .failure(let error): XCTFail("User Fetch Failed, Error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(users.count, 10)
        }
    }

    func testFetchWithGroup_LeavesGroupAfterReturningUsers() {
        let userExpectation = expectation(description: "UserFetch")
        var users = [User]()
        usersClient.fetch(group: userGroup) { result in
            switch result {
            case .success(let fetchedUsers): users = fetchedUsers
            case .failure(let error): XCTFail("User Fetch Failed, Error: \(error.localizedDescription)")
            }
        }
        
        userGroup.notify(queue: DispatchQueue.main) {
            userExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(users.count, 10)
        }
    }
    
}
