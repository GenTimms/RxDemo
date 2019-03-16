//
//  PostCellTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 26/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostCellTests: XCTestCase {
    
    var cell: PostCell!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostListViewController") as! PostListViewController
        
       controller.loadViewIfNeeded()
        
        let tableView = controller.tableView
        let dataSource = FakeDataSource()
        tableView?.dataSource = dataSource
        
        cell = (tableView?.dequeueReusableCell(withIdentifier: "Post Cell", for: IndexPath(row: 0, section: 0)) as! PostCell)
    }
    
    func testHasTitleLabel() {
        XCTAssertTrue(cell.titleLabel.isDescendant(of: cell.contentView))
    }
    
    func testConfigCell_SetsTitle() {
        let title = "A Post"
        
        cell.configure(with: PostCellViewModel(title: title))
        XCTAssertEqual(cell.titleLabel.text, title)
    }
    
}

extension PostCellTests {
    class FakeDataSource: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
}
