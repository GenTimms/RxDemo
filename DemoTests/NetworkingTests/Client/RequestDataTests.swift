//
//  RequestDataTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 29/01/2019.
//  Copyright © 2019 GMJT. All rights reserved.
//

@testable import Demo
import Foundation
import XCTest
import RxSwift
import RxBlocking

class RequestDataTests: XCTestCase {
    
    var sut: RequestData!
    var fakeData = ClientData.fakeData!
    
    override func setUp() {
            sut = RequestData()
    }
    
    func testSessionObservableForPostTypeReturnsFakeObservableData() {
        
        let disposeBag = DisposeBag()
        
        sut.postSessionObservable = Observable.just(fakeData)
        var data: Data? = nil
        
        sut.sessionObservable(for: Post.self)?
            .subscribe(onNext: {data = $0})
            .disposed(by: disposeBag)
        
        XCTAssertEqual(data, ClientData.fakeData)
    }
    
    func xtestLiveSessionObservableForTypeReturnsCorrespondingObservable() {
        
        var fetchedComments: [Comment]? = nil
        let fakeComments: [Comment]? = try? ClientData.commentData.createArray(ofType: Comment.self)
        
        if let data =  try? sut.sessionObservable(for: Comment.self)?.toBlocking().first() {
            if let comments = try? data?.createArray(ofType: Comment.self) {
                fetchedComments = comments
            }
        }
        
    XCTAssertNotNil(fakeComments)
    XCTAssertNotNil(fetchedComments)
    XCTAssertEqual(fetchedComments?.count, fakeComments?.count)
    }
    
    func testNilRequestReturnsNilObservable() {
        sut.postRequest = nil
        XCTAssertNil(sut.sessionObservable(for: Post.self))
    }
}

