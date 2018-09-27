//
//  PostDetailViewControllerTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 27/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostDetailViewControllerTests: XCTestCase {
    
    var sut: PostDetailViewController!
    let post = ModelStubs.posts[0]
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
        sut.post = post
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_HasPostDetailView() {
        XCTAssertTrue(sut.postDetailView.isDescendant(of: sut.view))
    }
    
    func test_viewDidLoadConfiguresDetailView() {
        let postDetailView = sut.postDetailView as! PostDetailView
        XCTAssertEqual(postDetailView.bodyLabel.text, post.body)
        XCTAssertEqual(postDetailView.userLabel.text, post.user?.name)
        XCTAssertEqual(postDetailView.commentCountLabel.text, "Comments: \(post.comments.count)")
    }
    
}
