//
//  DemoEndpointTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostsEndpointsEndpointTests: XCTestCase {
  
    let demoPostsURL = URL(string: "http://jsonplaceholder.typicode.com/posts")
    let demoCommentsURL = URL(string: "http://jsonplaceholder.typicode.com/comments")
    let demoUsersURL = URL(string: "http://jsonplaceholder.typicode.com/users")

    func testEndpointURLs_equalDemoAPIURLs() {
        
        //Posts
        let postsURL = PostsEndpoints.posts.url
        XCTAssertEqual(postsURL, demoPostsURL)
        
        //Comments
        let commentsURL = PostsEndpoints.comments.url
        XCTAssertEqual(commentsURL, demoCommentsURL)
        
        //Users
        let usersURL = PostsEndpoints.users.url
        XCTAssertEqual(usersURL, demoUsersURL)
    }
    
    func testEndpointRequest_equalsURLRequest() {
        
        //Posts
        let postsRequest = PostsEndpoints.posts.request
        XCTAssertEqual(postsRequest, URLRequest(url: demoPostsURL!))
        
        //Comments
        let commentsRequest = PostsEndpoints.comments.request
        XCTAssertEqual(commentsRequest, URLRequest(url: demoCommentsURL!))
        
        //Users
        let usersRequest = PostsEndpoints.users.request
        XCTAssertEqual(usersRequest, URLRequest(url: demoUsersURL!))
    }
}
