//
//  PostDetailViewTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 26/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostDetailViewTests: XCTestCase {
    
    var detailView: PostDetailView!
    let viewModel = PostDetailViewModel(body: "Post Body", user: "Gen Timms", commentCount: "5")
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
        
        controller.loadViewIfNeeded()
        detailView = controller.postDetailView as! PostDetailView
    }
    
    func testHasBodyLabel() {
        XCTAssertTrue(detailView.bodyLabel.isDescendant(of: detailView))
    }
    
    func testHasUserLabel() {
        XCTAssertTrue(detailView.userLabel.isDescendant(of: detailView))
    }
    
    func testHasCommentCountLabel() {
        XCTAssertTrue(detailView.commentCountLabel.isDescendant(of: detailView))
    }
    
    func testConfig_SetsBodyLabel() {
        detailView.configure(with: viewModel)
        XCTAssertEqual(detailView.bodyLabel.text, "Post Body")
    }
    
    func testConfig_SetsUserLabel() {
        detailView.configure(with: viewModel)
        XCTAssertEqual(detailView.userLabel.text, "Gen Timms")
    }
    
    func testConfig_SetsCommentCountLabel() {
        detailView.configure(with: viewModel)
        XCTAssertEqual(detailView.commentCountLabel.text, "5")
    }
}
