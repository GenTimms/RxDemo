//
//  PostListViewControllerTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 18/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
import CoreData
import UIKit
import RxSwift

@testable import Demo

class PostListViewControllerTests: XCTestCase {
    
    var sut: PostListViewController!
    
    let persistentContainer = CoreDataTestStack().mockPersistentContainer
    
    var client: MockPostsClient!
    var storageManager: MockPostStorageManager!
    
    override func setUp() {
        sut = createPostListViewController()
        
        client = MockPostsClient()
        storageManager = MockPostStorageManager(container: persistentContainer)
        
        sut.client = client
        sut.storageManager = storageManager
        
        sut.loadViewIfNeeded()
        UIApplication.shared.keyWindow?.rootViewController = sut
    }
    
    private func createPostListViewController() -> PostListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PostListViewController") as! PostListViewController
        controller.loadViewIfNeeded()
        return controller
    }
    
    func testInitiateFetch_SetsDataSource() {
        sut.initiateFetch()
        XCTAssertNotNil(sut.tableView.dataSource as? PostListDataSource)
    }
    
    func testInitiateFetch_WithNilClient_Returns() {
        sut.client = nil
        sut.initiateFetch()
        XCTAssertNil(sut.tableView.dataSource as? PostListDataSource)
    }
    
    func testInitiateFetch_WithNilStorageManager_Returns() {
        sut.storageManager = nil
        sut.initiateFetch()
        XCTAssertNil(sut.tableView.dataSource as? PostListDataSource)
        if let client = sut.client as? MockPostsClient {
            XCTAssertFalse(client.fetchCalled)
        }
    }
    
    func testInitiateFetch_callsFetchPosts() {
        sut.initiateFetch()
        if let client = sut.client as? MockPostsClient {
            XCTAssertTrue(client.fetchCalled)
        }
    }
    
    func testSuccessfulFetch_InsertsPostsIntoStorageManager() {
        sut.initiateFetch()
        let storageManager = sut.storageManager as! MockPostStorageManager
        XCTAssertEqual(ModelStubs.posts.count, storageManager.insertedPosts.count)
    }
    
    func testSuccessfulFetch_WithStorageManagerInsertionError_DisplaysErrorNotification() {
        storageManager.insertionError = true
        sut.storageManager = storageManager
        sut.initiateFetch()
        
        let alertController: UIAlertController? = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(alertController)
    }
    
    func testFailedFetch_DisplaysErrorNotification() {
        client.success = false
        sut.initiateFetch()
        
        let alertController: UIAlertController? = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(alertController)
    }
    
    func testSuccessfulFetch_callsDataProviderFetchData() {
        let mockDataProvider = MockDataProvider(storageManager: storageManager)
        sut.dataProvider = mockDataProvider
        sut.initiateFetch()
        XCTAssertTrue(mockDataProvider.fetchDataCalled)
    }
    
    func testSuccessfulFetch_ReloadsTableView() {
        let tableView = MockTableView()
        sut.tableView = tableView
        sut.initiateFetch()
        
        XCTAssertTrue(tableView.reloadCalled)
    }
    
    func testFailedDataProviderFetch_DisplaysError() {
        let mockDataProvider = MockDataProvider(storageManager: storageManager)
        mockDataProvider.fetchError = true
        sut.dataProvider = mockDataProvider
        
        sut.initiateFetch()
        let alertController = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(alertController)
    }
    
    func testSelectingRow_PerformsSegue() {

        let dataSource = MockDataSource()
        sut.dataProvider = MockDataProvider(storageManager: storageManager)
        sut.loadViewIfNeeded()
        sut.tableView.dataSource = dataSource
        sut.tableView.delegate = sut
        sut.tableView.reloadData()

        sut.tableView.delegate!.tableView!(sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        
        guard let detailViewController = sut.presentedViewController?.contents as? PostDetailViewController else {
            return XCTFail()
        }
        
        XCTAssertNotNil(detailViewController.post)
        XCTAssertEqual(detailViewController.post?.id, ModelStubs.posts[0].id)
    }
}

extension PostListViewControllerTests {
    
    class MockDataProvider: PostDataProvider {
        var fetchDataCalled = false
        var fetchError = false
        override func fetchData(completion: (Error?) -> Void)
        {
            if fetchError {
                completion(ClientData.error)
            }
            fetchDataCalled = true
        }
        
        override func objectAt(indexPath: IndexPath) -> Post {
            return ModelStubs.posts[0]
        }
    }
    
    class MockTableView: UITableView {
        var reloadCalled = false
        override func reloadData() {
            reloadCalled = true
        }
    }
    
    class MockPostsClient: RxPostsClient {
        var fetchCalled = false
        var success = true
        
        override func fetch() -> Single<[Post]> {
            fetchCalled = true
            return Single<[Post]>.create { single in
                if self.success {
                    single(.success(ModelStubs.posts))
                } else {
                    single(.error(ClientData.error))
                }
                return Disposables.create {}
            }
        }
    }
    
    class MockFetchedResultsController: NSFetchedResultsController<CDPost> {
        var fetchCalled = false
        var fetchSucceeds = true
        
        override func performFetch() throws {
            fetchCalled = true
            if !fetchSucceeds {
                throw ClientData.error
            }
        }
    }
    
    class MockPostStorageManager: PostStorageManager {
        var insertionError = false
        var insertedPosts = [Post]()
        
        override func createFetchedResultsController() -> NSFetchedResultsController<CDPost> {
            return MockFetchedResultsController()
        }
        
        override func insert(_ posts: [Post], completion: @escaping (Error?) -> Void) {
            if insertionError {
                completion(ClientData.error)
            }
            insertedPosts = posts
        }
    }
    
    class MockDataSource: NSObject, UITableViewDataSource {
        
        var posts = ModelStubs.posts
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return posts.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: Cells.postCell, for: indexPath)
            if let postCell = cell as? PostCell {
            postCell.configure(with: PostCellViewModel(post: posts[indexPath.row]))
            }
            return cell
        }
    }
}
