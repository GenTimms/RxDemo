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

class PostsClientTests: XCTestCase {
    
    var sut: RxPostsClient!
    var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        
        sut = RxPostsClient()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    //MARK: - Live Testing
    func testLiveFetch_FetchesCompletedPosts() {
        
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
    
    func testLiveFetch_WithFakeURL_ReturnsError() {
        sut.requestData.postRequest = URLRequest(url: URL(string: "http://fakeURL.com")!)
        XCTAssertThrowsError(try sut.fetch().asObservable().toBlocking().single())
    }
    
    func testLiveFetch_WithNilRequest_ReturnsError() {
        sut.requestData.postRequest = nil
        XCTAssertThrowsError(try sut.fetch().asObservable().toBlocking().single())
    }
    

    func injectMockObservables() {
        sut.requestData.postSessionObservable = scheduler.createHotObservable([
            next(600, ClientData.postData!)]).asObservable()
        sut.requestData.commentSessionObservable = scheduler.createHotObservable([
            next(400, ClientData.commentData!)]).asObservable()
        sut.requestData.userSessionObservable = scheduler.createHotObservable([
            next(200, ClientData.userData!)]).asObservable()
    }

    func testFetchReturnsCompletedPosts() {

        let disposeBag = DisposeBag()
        injectMockObservables()

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
        injectMockObservables()
        
        sut.requestData.postSessionObservable = nil
        sut.requestData.postRequest = nil

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

        injectMockObservables()

            sut.requestData.userSessionObservable = scheduler.createHotObservable([
                error(200, RequestError.invalidResponse)]).asObservable()

        var caughtError: Error? = nil

        sut.fetch().asObservable()
            .subscribe(onNext: { XCTFail("Fetch succeeded with userErrorObservable event: \($0)") },
                       onError: { caughtError = $0 })
            .disposed(by: disposeBag)

        scheduler.start()
        XCTAssertNotNil(caughtError as? RequestError)
    }

    func testFetch_withFakeData_ReturnsDecodingError() {
        let disposeBag = DisposeBag()
        
        injectMockObservables()
        sut.requestData.commentSessionObservable = scheduler.createHotObservable([next(300, ClientData.fakeData!)]).asObservable()

        var caughtError: Error? = nil

        sut.fetch().asObservable()
            .subscribe(onNext: { XCTFail("Fake data succeeded, event: \($0)") },
                       onError: { caughtError = $0 })
            .disposed(by: disposeBag)

        scheduler.start()
        XCTAssertNotNil(caughtError as? Swift.DecodingError)
    }

    func testSecondFetch() {

            let disposeBag = DisposeBag()
            injectMockObservables()

            sut.fetch().asObservable()
                .debug()
                .subscribe(onNext: { print("Posts: \($0)") },
                           onError: {  print("Error: \($0)")
                })
                .disposed(by: disposeBag)

            scheduler.start()

        injectMockObservables()
        sut.fetch().asObservable()
            .debug()
            .subscribe(onNext: { print("Posts 2: \($0)") },
                       onError: {  print("Error 2: \($0)")
            })
            .disposed(by: disposeBag)

        scheduler.start()
        }
    
    func xtestLiveSecondFetch() {

        let posts1 = try? sut.fetch().toBlocking().single()
        let posts2 =  try? sut.fetch().toBlocking().single()
        
        print("Posts 1: \(posts1)")
        print("Posts 2: \(posts2)")
    }
}




