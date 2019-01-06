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
        
        var posts = [Post]()
        var caughtError: Error? = nil
        
        do {
            posts = try sut.fetch().asObservable().toBlocking().single()
        } catch {
            caughtError = error
        }
        
        XCTAssertNil(caughtError)
        XCTAssertEqual(posts.count, 100)
        let commentCounts = Set(posts.map{$0.comments.count})
        let have5Comments = commentCounts.count == 1 ? commentCounts.first == 5 ? true : false : false
        let haveUsers = posts.compactMap{$0.user}.count == 100
        let areCompleted = have5Comments && haveUsers
        XCTAssert(areCompleted)
    }
    
    func xtestLiveFetch_WithFakeURL_ReturnsError() {
        sut.postRequest = URLRequest(url: URL(string: "http://fakeURL.com")!)
        XCTAssertThrowsError(try sut.fetch().asObservable().toBlocking().single())
    }
    
    func xtestLiveFetch_WithNilRequest_ReturnsError() {
        sut.postRequest = nil
        XCTAssertThrowsError(try sut.fetch().asObservable().toBlocking().single())
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
        
        let disposeBag = DisposeBag()
        createSingles()
        
        var posts = [Post]()
        
        sut.fetch().asObservable()
            .subscribe(onNext: { posts = $0 },
                       onError: { XCTFail("Posts Fetch Failed: Error \($0.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(posts.count,100)
        
        let commentCounts = Set(posts.map{$0.comments.count})
        let have5Comments = commentCounts.count == 1 ? commentCounts.first == 5 ? true : false : false
        let haveUsers = posts.compactMap{$0.user}.count == 100
        let areCompleted = have5Comments && haveUsers
        XCTAssert(areCompleted)
    }
    
    func testFetch_WithNilRequest_ReturnsError() {
        
        let disposeBag = DisposeBag()
        sut.postRequest = nil
        
        createSingles()
        var caughtError: Error? = nil
        
        sut.fetch().asObservable()
            .subscribe(onNext: { XCTFail("Fetch succeeded with fake request, received next event: \($0)") },
                       onError: { caughtError = $0 })
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertNotNil(caughtError as? RequestError)
    }
    
    func testFetch_withNetworkError_ReturnsError() {
        
        let disposeBag = DisposeBag()
        
        userObservable = scheduler.createHotObservable([
            error(200, RequestError.invalidResponse)])
        
        createSingles()
        
        var caughtError: Error? = nil
        
        sut.fetch().asObservable()
            .subscribe(onNext: { XCTFail("Fetch succeeded with userErrorObservable event: \($0)") },
                       onError: { caughtError = $0 })
            .disposed(by: disposeBag)
        
        _ = usersSingle.asObservable().subscribe{ print("UserSingle Event: \($0)") }
        
        scheduler.start()
        XCTAssertNotNil(caughtError as? RequestError)
    }
    
    func testFetch_withFakeData_ReturnsDecodingError() {
        let disposeBag = DisposeBag()
        commentObservable = scheduler.createHotObservable([next(300, ClientData.fakeData!)])
        
        createSingles()
        
        var caughtError: Error? = nil
        
        sut.fetch().asObservable()
            .subscribe(onNext: { XCTFail("Fake data succeeded, event: \($0)") },
                       onError: { caughtError = $0 })
            .disposed(by: disposeBag)
        
        scheduler.start()
        XCTAssertNotNil(caughtError as? Swift.DecodingError)
    }
}




