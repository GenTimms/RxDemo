//
//  DemoEndpointTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class DemoEndpointTests: XCTestCase {
    
    let demoPostsURL = URL(string: "http://jsonplaceholder.typicode.com/posts")
    let demoCommentsURL = URL(string: "http://jsonplaceholder.typicode.com/comments")
    let demoUsersURL = URL(string: "http://jsonplaceholder.typicode.com/users")

    func testEndpointURLs_equalDemoAPIURLs() {
        
        //Posts
        let postsURL = Demo.posts.url
        XCTAssertEqual(postsURL, demoPostsURL)
        
        //Comments
        let commentsURL = Demo.comments.url
        XCTAssertEqual(commentsURL, demoCommentsURL)
        
        //Users
        let usersURL = Demo.users.url
        XCTAssertEqual(usersURL, demoUsersURL)
        
    }
    
    func testEndpointRequest_equalsURLRequest() {
        
        //Posts
        let postsRequest = Demo.posts.request
        XCTAssertEqual(postsRequest, URLRequest(url: demoPostsURL!))
        
        //Comments
        let commentsRequest = Demo.comments.request
        XCTAssertEqual(commentsRequest, URLRequest(url: demoCommentsURL!))
        
        //Users
        let usersRequest = Demo.users.request
        XCTAssertEqual(usersRequest, URLRequest(url: demoUsersURL!))
        
    }
}
