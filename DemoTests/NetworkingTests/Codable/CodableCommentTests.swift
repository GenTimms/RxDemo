//
//  CodableCommentTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class CodableCommentTests: XCTestCase {
    
    let data: Data! = {
        
        if let path = Bundle.main.path(forResource: "comments", ofType: "json") {
            print("Path Found")
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    override func setUp() {
        super.setUp()
        guard data != nil else {
            XCTFail("Can't get JSON Data")
            return
        }
    }
    
    func testJSONDecoder_CreatesComments() {
        var users = [Comment]()
        do {
            users =  try JSONDecoder().decode([Comment].self, from: data)
        } catch  {
            XCTFail("JSON Error: \(error)")
        }
        XCTAssert(!users.isEmpty)
    }
    
    func testCreateComments_CreatesComments() {
        guard let comments = try? data.createArray(ofType: Comment.self) else {
            XCTFail("data.createArray(ofType: Comment.self) Failed")
            return
        }
        XCTAssert(!comments.isEmpty)
    }
    
    func testCreateComments_throwsError() {
        
        var caughtError: Error? = nil
        
        do {
            _ = try Data().createArray(ofType: Comment.self)
        } catch {
            caughtError = error
        }
        
        XCTAssertNotNil(caughtError)
        print(caughtError.debugDescription)
    }
}
