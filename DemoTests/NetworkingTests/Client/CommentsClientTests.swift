//
//  CommentsClientTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 06/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class CommentsClientTests: XCTestCase {
    
    var mockURLSession: MockURLSession!
    var commentsClient: CommentsClient!
    
    let commentsGroup = DispatchGroup()
    
    let response =  HTTPURLResponse(url: URL(string: "http://jsonplaceholder.typicode.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    
    let commentData: Data! = {
        if let path = Bundle.main.path(forResource: "comments", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    override func setUp() {
        super.setUp()
        mockURLSession = MockURLSession(data: commentData, urlResponse: response, error: nil)
        commentsClient = CommentsClient()
        commentsClient.session = mockURLSession
    }
    
    func testFetch_ReturnsComments() {
        var comments = [Comment]()
        let commentsExpectation = expectation(description: "Comments Expectation")
        
        commentsClient.fetch { result in
            switch result {
            case .success(let fetchedComments): comments = fetchedComments; commentsExpectation.fulfill()
            case .failure(let error): XCTFail("Comments Fetch Failed, Error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(comments.count, 500)
        }
    }
    
    func testFetchWithGroup_LeavesGroupAfterReturningComments() {
        var comments = [Comment]()
        let commentsExpectation = expectation(description: "Comments Expectation")
        
        commentsClient.fetch(group: commentsGroup) { result in
            switch result {
            case .success(let fetchedComments): comments = fetchedComments
            case .failure(let error): XCTFail("Comments Fetch Failed, Error: \(error.localizedDescription)")
            }
        }
        
        commentsGroup.notify(queue: DispatchQueue.main) {
            commentsExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(comments.count, 500)
        }
        
    }
    
    
}
