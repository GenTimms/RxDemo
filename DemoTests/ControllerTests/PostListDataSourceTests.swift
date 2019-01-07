//
//  PostListDataSourceTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
@testable import Demo

class PostListDataSourceTests: XCTestCase {
    
    let postCount = ModelStubs.posts.count
    
    var coreDataStack: CoreDataTestStack!
    var fetchedResultsController: NSFetchedResultsController<CDPost>!
    var sut: PostListDataSource!
    
    var tableView: UITableView!
    
    override func setUp() {
        coreDataStack = CoreDataTestStack()
        
        fetchedResultsController = createFetchedResultsController()
        sut = PostListDataSource(fetchedResultsController: fetchedResultsController)
        
        tableView = createTableView()
    }
    
    private func createFetchedResultsController() -> NSFetchedResultsController<CDPost> {
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.mainContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
    }
    
    private func createTableView() -> UITableView? {
        let controller = createPostListViewController()
        if let tableView = controller.tableView {
            tableView.delegate = controller
            tableView.dataSource = sut
            return tableView
        }
        return nil
    }
    
    private func createPostListViewController() -> PostListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostListViewController") as! PostListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    private func addAndFetchPosts() {
        coreDataStack.createStubs()
        
        do { try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            XCTFail("FetchedResultController fetch failed")
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testNumberOfSections_IsOne() {
        addAndFetchPosts()
        XCTAssertEqual(tableView.numberOfSections, 1)
    }
    
    func testNumberOfRows_equalsPostCount() {
        addAndFetchPosts()
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), postCount)
    }
    
    func testNumberOfSections_IsOne_WhenEmptyDataFetched() {
        XCTAssertEqual(tableView.numberOfSections, 1)
    }
    
    func testNumberOfRows_equalsZero_WhenEmptyDataFetched() {
        XCTAssertEqual(tableView.numberOfRows(inSection: 0), 0)
    }
    
    func testCellForRow_DequeuesReuseableCell() {
        addAndFetchPosts()
        let tableView = MockTableView()
        tableView.dataSource = sut
        tableView.register(MockPostCell.self, forCellReuseIdentifier: Cells.postCell)
        tableView.reloadData()
        
        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(tableView.dequeueWasCalled, true)
    }
    
    func testCellForRow_ConfiguresCellWithPostTitle() {
        addAndFetchPosts()
        let tableView = MockTableView()
        tableView.dataSource = sut
        tableView.register(MockPostCell.self, forCellReuseIdentifier: Cells.postCell)
        tableView.reloadData()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? MockPostCell {
            XCTAssertEqual(cell.catchedTitle, ModelStubs.posts[0].title)
        } else {
            XCTFail("Can't get MockPostCell")
        }
    }
}

extension PostListDataSourceTests {
    class MockTableView: UITableView {
        var dequeueWasCalled = false
        override func dequeueReusableCell(withIdentifier identifier: String,
                                          for indexPath: IndexPath) -> UITableViewCell {
            dequeueWasCalled = true
            return super.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        }
    }
    
    class MockPostCell: PostCell {
        var catchedTitle: String?
        
        override func configure(with viewModel: PostCellViewModel) {
            catchedTitle = viewModel.title
        }
    }
}
