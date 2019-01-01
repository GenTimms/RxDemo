//
//  RxPostsClientTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 18/12/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
import RxTest
import RxBlocking
import RxSwift
import XCTest
@testable import Demo

class RxPostsClientTests: XCTestCase {
    
    var sut: RxPostsClient!
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        sut = RxPostsClient()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    //MARK: - Live Testing
    func xtestLiveFetch_FetchesCompletedPosts() {
        let fetchExpectation = expectation(description: "Fetch Expectation")
        var posts = [Post]()
        
        sut.fetch { result in
            switch result {
            case .success(let fetchedPosts): posts = fetchedPosts; fetchExpectation.fulfill()
            case .failure(let error): XCTFail("Posts Fetch Failed: Error \(error.localizedDescription)")
            print(error )
            }
        }
        
        waitForExpectations(timeout: 3) { _ in
            XCTAssertEqual(posts.count, 100)
            
            let commentCounts = Set(posts.map{$0.comments.count})
            let have5Comments = commentCounts.count == 1 ? commentCounts.first == 5 ? true : false : false
            let haveUsers = posts.compactMap{$0.user}.count == 100
            let areCompleted = have5Comments && haveUsers
            XCTAssert(areCompleted)
        }
    }
    
    func xtestLiveFetch_WithFakeURL_ReturnsError() {
        let fetchExpectation = expectation(description: "FetchExpectation")
        var caughtError: Error? = nil
        sut.postRequest = URLRequest(url: URL(string: "http://fakeURL.com")!)
        sut.fetch { result in
            switch result {
            case .success(_): XCTFail("Fetch successed with fake request")
            case .failure(let error): fetchExpectation.fulfill(); caughtError = error
            }
        }
        
        waitForExpectations(timeout: 3) { _ in
            XCTAssertNotNil(caughtError)
            print(caughtError)
        }
    }
    
    func xtestLiveFetch_WithNilRequest_ReturnsError() {
        let fetchExpectation = expectation(description: "FetchExpectation")
        var caughtError: Error? = nil
        sut.postRequest = nil
        sut.fetch { result in
            switch result {
            case .success(_): XCTFail("Fetch successed with fake request")
            case .failure(let error): fetchExpectation.fulfill(); caughtError = error
            }
        }
        
        waitForExpectations(timeout: 3) { _ in
            XCTAssertNotNil(caughtError)
            print(caughtError)
        }
    }
    
    //MARK: - Mock Testing
    
    var postsSingle: PrimitiveSequence<SingleTrait, [Post]>!
    var commentsSingle: PrimitiveSequence<SingleTrait, [Comment]>!
    var usersSingle: PrimitiveSequence<SingleTrait, [User]>!
    
    lazy var postObservable = scheduler.createHotObservable([
        next(600, ClientData.postData!)])
    lazy var commentObservable = scheduler.createHotObservable([
        next(400, ClientData.commentData!)])
    lazy var userObservable = scheduler.createHotObservable([
        next(200, ClientData.userData!)])
    
    func createSingles() {
        sut.sessionObservable = postObservable.asObservable()
        postsSingle = sut.postsSingle
        
        sut.sessionObservable = commentObservable.asObservable()
        commentsSingle = sut.commentsSingle
        
        sut.sessionObservable = userObservable.asObservable()
        usersSingle = sut.usersSingle
    }
    
    func testSinglesReturnParsedData() {
        
        let disposeBag = DisposeBag()
        
        createSingles()
        
        let postObserver = scheduler.createObserver([Post].self)
        let commentObserver = scheduler.createObserver([Comment].self)
        let userObserver = scheduler.createObserver([User].self)
        
        postsSingle.asObservable().subscribe(postObserver).disposed(by: disposeBag)
        commentsSingle.asObservable().subscribe(commentObserver).disposed(by: disposeBag)
        usersSingle.asObservable().subscribe(userObserver).disposed(by: disposeBag)
        
        scheduler.start()
        
        let posts = postObserver.events.first!.value.element!
        let comments = commentObserver.events.first!.value.element!
        let users = userObserver.events.first!.value.element!
        
        XCTAssertEqual(posts.count, 100)
        XCTAssertEqual(comments.count, 500)
        XCTAssertEqual(users.count, 10)
    }
    
    func testFetchReturnsCompletedPosts() {
        
        createSingles()
        
        let fetchExpectation = expectation(description: "Fetch Expectation")
        var posts = [Post]()
        
        sut.fetch { result in
            switch result {
            case .success(let fetchedPosts): posts = fetchedPosts; fetchExpectation.fulfill()
            case .failure(let error): XCTFail("Posts Fetch Failed: Error \(error.localizedDescription)")
            print(error )
            }
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 3) { _ in
            XCTAssertEqual(posts.count,100)
            
            let commentCounts = Set(posts.map{$0.comments.count})
            let have5Comments = commentCounts.count == 1 ? commentCounts.first == 5 ? true : false : false
            let haveUsers = posts.compactMap{$0.user}.count == 100
            let areCompleted = have5Comments && haveUsers
            XCTAssert(areCompleted)
        }
    }
    
    func testFetch_WithNilRequest_ReturnsError() {
        
        sut.postRequest = nil
        
        createSingles()
        
        let fetchExpectation = expectation(description: "FetchExpectation")
        var caughtError: Error? = nil
        
        sut.fetch { result in
            switch result {
            case .success(_): XCTFail("Fetch succeeded with fake request")
            case .failure(let error): fetchExpectation.fulfill(); caughtError = error
            }
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 3) { _ in
            XCTAssertNotNil(caughtError)
            print(caughtError)
        }
    }
    
    func testFetch_withNetworkError_ReturnsError() {
        
        userObservable = scheduler.createHotObservable([
            error(200, RequestError.invalidResponse)])
        
        createSingles()
        
        let fetchExpectation = expectation(description: "FetchExpectation")
        var caughtError: Error? = nil
        
        sut.fetch { result in
            switch result {
            case .success(_): XCTFail("Fetch succeeded with userErrorObservable")
            case .failure(let error): fetchExpectation.fulfill(); caughtError = error
            }
        }
        
        _ = usersSingle.asObservable().subscribe{ print("UserSingle Event: \($0)") }
        
        scheduler.start()
        
        waitForExpectations(timeout: 3) { _ in
            XCTAssertNotNil(caughtError)
            print(caughtError)
        }
    }
    
    func testFetch_withFakeData_ReturnsDecodingError() {
        commentObservable = scheduler.createHotObservable([next(300, ClientData.fakeData!)])
        
        createSingles()
        
        let fetchExpectation = expectation(description: "Fetch Expectation")
        var caughtError: Error? = nil
        
        sut.fetch {
            switch $0 {
            case .success: XCTFail("Fake data succeeded");
            case .failure(let error): caughtError = error; fetchExpectation.fulfill()
            }
        }
        
        scheduler.start()
        
        waitForExpectations(timeout: 3) { _ in
            XCTAssertNotNil(caughtError)
            XCTAssertNotNil(caughtError as? Swift.DecodingError)
        }
    }
}




