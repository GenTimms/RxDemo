//
//  PostsClientTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostsClientTests: XCTestCase {
    
    var sut: PostsClient!
    
    var commentsClient: CommentsClient!
    var usersClient: UsersClient!
    
    override func setUp() {
        super.setUp()
        
        sut = PostsClient()
        commentsClient = CommentsClient()
        usersClient = UsersClient()
        
        sut.session = MockURLSession(data: ClientData.postData, urlResponse: ClientData.response, error: nil)
        commentsClient.session = MockURLSession(data: ClientData.commentData, urlResponse: ClientData.response, error: nil)
        usersClient.session = MockURLSession(data: ClientData.userData, urlResponse: ClientData.response, error: nil)
        
        sut.commentsClient = commentsClient
        sut.usersClient = usersClient
    }
    
    func testFetch_ReturnsPosts() {
        let postsExpectation = expectation(description: "Posts Expectation")
        var posts = [Post]()
        
        sut.fetch { result in
            switch result {
            case .success(let fetchedPosts): posts = fetchedPosts; postsExpectation.fulfill()
            case .failure(let error): XCTFail("Posts Fetched Failed: Error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(posts.count, 100)
        }
    }
    
    
    func testFetch_withComponentErrors_ReturnsError() {
        
        sut.session = MockURLSession(data: nil, urlResponse: nil, error: nil)
        commentsClient.session = MockURLSession(data: nil, urlResponse: nil, error: nil)
        usersClient.session = MockURLSession(data: nil, urlResponse: nil, error: nil)
        
        let postsExpectation = expectation(description: "Posts Expectation")
        var caughtError: Error? = nil
        
        sut.fetch { result in
            switch result {
            case .success: XCTFail("Nil Session Succeeded")
            case .failure(let error): caughtError = error; postsExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertNotNil(caughtError)
            XCTAssertEqual(self.sut.errors.count, 3)
        }
    }
}










