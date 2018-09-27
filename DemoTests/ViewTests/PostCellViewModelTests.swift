//
//  PostCellViewModelTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 27/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostCellViewModelTests: XCTestCase {
    
    var postCellViewModel: PostCellViewModel!
    
    override func setUp() {
        super.setUp()
    }
    
    func testInitWithPost_SetsTitle() {
        postCellViewModel = PostCellViewModel(post: ModelStubs.posts[0])
        XCTAssertEqual(postCellViewModel.title, ModelStubs.posts[0].title)
    }
    
}
