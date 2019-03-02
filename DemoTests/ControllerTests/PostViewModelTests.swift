//
//  PostViewModelTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 02/02/2019.
//  Copyright © 2019 GMJT. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import RxBlocking
import RxCocoa

@testable import Demo

class PostViewModelTests: XCTestCase {
    
    static let nilError =  NSError(domain: "Nil Mock Observable", code: 1234, userInfo: nil)
    static let networkError =  NSError(domain: "Network Error", code: 1111, userInfo: nil)
    static let databaseError =  NSError(domain: "Database Error", code: 2222, userInfo: nil)
    static let insertError = NSError(domain: "Insert Error", code: 3333, userInfo: nil)
    
    var sut: PostViewModel!
    var storageManager: MockPostStorageManager!
    var client: MockClient!
    
    var scheduler: TestScheduler!
    var subscription: Disposable!
    
    let databasePosts = [ModelStubs.posts[0], ModelStubs.posts[1]]
    let networkPosts = ModelStubs.posts
    
    lazy var networkResult = Observable.just(networkPosts).asSingle()
    lazy var databaseResult = Observable.just(databasePosts).asSingle()
    
    override func setUp() {
        super.setUp()
        storageManager = MockPostStorageManager()
        storageManager.fetchResult = databaseResult
        client = MockClient()
        client.fetchResult = networkResult

        sut = PostViewModel(client: client, storageManager: storageManager)
        scheduler = TestScheduler(initialClock: 0)
    }
    
    override func tearDown() {
        self.subscription.dispose()
        super.tearDown()
    }
    
   // MARK: - Fetching
    func testRefreshDataMethod_FetchesMockNetworkData() {
        var caughtResult: [Post]?
        var caughtError: Error?

        subscription = sut.networkData.subscribe(onNext: { caughtResult = $0
        }, onError: { caughtError = $0 })
        sut.refreshData()
        
        XCTAssertNil(caughtError)
        XCTAssertEqual(caughtResult, networkPosts)
    }
    
        func testDataBaseDataObservable_FetchesFromDatabase() {
            var caughtResult: [Post]?
            var caughtError: Error?
            
            subscription = sut.databaseData.subscribe(onNext: { caughtResult = $0
            }, onError: { caughtError = $0 })

            XCTAssertNil(caughtError)
            XCTAssertEqual(caughtResult, databasePosts)
        }
    
        //Data Driver
        func testDataDriver_SubscribedToNetworkData() {
            let observer = scheduler.createObserver([Post].self)
    
            scheduler.scheduleAt(0) {
                self.subscription = self.sut.data.drive(observer)
            }
    
            scheduler.scheduleAt(100) {
                self.sut.refreshData()
            }
    
            scheduler.start()
    
            let results = observer.events.map {
                $0.value.element!
            }
    
            if let first = results.first {
            XCTAssertEqual(first, networkPosts)
            } else {
            XCTFail("No Result")
            }
        }
    
        func testDataDriver_WithNetworkError_SubscribesToDatabaseFetch() {
            let observer = scheduler.createObserver([Post].self)
            
            client.fetchResult =  Single.error(PostViewModelTests.networkError)
            
            scheduler.scheduleAt(0) {
                self.subscription = self.sut.data.drive(observer)
            }
            
            scheduler.scheduleAt(100) {
                self.sut.refreshData()
            }
            
            scheduler.start()
            print(observer.events)
           
            if let first = observer.events.first {
                XCTAssertEqual(first.value.element, databasePosts)
            }
    }
    
        func testDataDriver_WithNetworkAndDatabaseError_EmitsEmptyArray() {
            let observer = scheduler.createObserver([Post].self)
            
            client.fetchResult = Single.error(PostViewModelTests.networkError)
            storageManager.fetchResult = Single.error(PostViewModelTests.databaseError)
            
            scheduler.scheduleAt(0) {
                self.subscription = self.sut.data.drive(observer)
            }
            
            scheduler.scheduleAt(100) {
                self.sut.refreshData()
            }
            
            scheduler.start()
            
            if let first = observer.events.first {
                XCTAssertEqual(first.value.element, [Post]())
            }
        }
    
        //MARK: - Errors
        func testErrorSubject_onNetworkError_EmitsErrorEvent() {
            let disposeBag = DisposeBag()
            var caughtError: Error?
            
            client.fetchResult = Single.error(PostViewModelTests.networkError)

            sut.data.asObservable().subscribe { print("Data Event: \($0)") }.disposed(by: disposeBag)
            subscription = sut.error.debug().subscribe(onNext: { caughtError = $0; print($0) })
            sut.refreshData()
            
            XCTAssertEqual(caughtError as NSError?, PostViewModelTests.networkError)
        }
    
        func testErrorSubject_onDatabaseFetchError_EmitsErrorEvent() {
            let disposeBag = DisposeBag()
            var caughtError: Error?
            
            storageManager.fetchResult = Single.error(PostViewModelTests.databaseError)
            client.fetchResult = Single.error(PostViewModelTests.networkError)
            
            sut.data.asObservable().subscribe { print("Data Event: \($0)") }.disposed(by: disposeBag)
            subscription = sut.error.subscribe(onNext: { caughtError = $0; print($0) })
            sut.refreshData()
            
            XCTAssertEqual(caughtError as NSError?, PostViewModelTests.databaseError)
        }
    
        func testErrorSubject_onDatabaseInsertError_EmitsErrorEvent() {
            storageManager.insertResult = Completable.error(PostViewModelTests.insertError)
            
            var caughtError: Error?
           
            subscription = sut.error.subscribe(onNext: { caughtError = $0; print($0) })
            sut.refreshData()
            
            XCTAssertEqual(caughtError as NSError?, PostViewModelTests.insertError)
        }
}

extension PostViewModelTests {
    class MockPostStorageManager: PostStorageManager {

        var fetchResult: Single<[Post]>?
        var insertResult: Completable?
        
        override func fetch() -> PrimitiveSequence<SingleTrait, Array<Post>> {
                return fetchResult ?? Single.error(PostViewModelTests.nilError)
        }

        override func rxInsert(_ posts: [Post]) -> Completable {
                return insertResult ?? Completable.error(PostViewModelTests.nilError)
        }
    }
    
    class MockClient: RxPostsClient {

        var fetchResult: Single<[Post]>?

        override func fetch() -> PrimitiveSequence<SingleTrait, Array<Post>> {
                return fetchResult ?? Single.error(PostViewModelTests.nilError)
        }
    }
}
