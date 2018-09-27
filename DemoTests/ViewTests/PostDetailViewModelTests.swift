//
//  PostDetailViewModelTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 27/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostDetailViewModelTests: XCTestCase {
    
    var postDetailViewModel: PostDetailViewModel!
    var post: Post!
    
    override func setUp() {
        super.setUp()
        post = ModelStubs.posts[0]
        postDetailViewModel = PostDetailViewModel(post: post)
        
    }
    
    func testInitWithPost_SetsBody() {
        XCTAssertEqual(postDetailViewModel.body, post.body)
    }
    
    func testInitWithPost_SetsUser() {
        XCTAssertEqual(postDetailViewModel.user, post.user?.name)
    }
    
    func testInitWithPostWithNilUser_SetsUserToAnonymous() {
        post.user = nil
        postDetailViewModel = PostDetailViewModel(post: post)
        XCTAssertEqual(postDetailViewModel.user, "Anonymous User")
    }
    
    func testInitWithPosts_SetsCommentCount() {
        XCTAssertEqual(postDetailViewModel.commentCount, "Comments: " + String(post.comments.count))
    }
    
    
    
    
}
