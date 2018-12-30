//
//  CodablePostTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class CodablePostTests: XCTestCase {
    
    let data: Data! = {
        if let path = Bundle.main.path(forResource: "posts", ofType: "json") {
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
    
    func testJSONDecoder_CreatesUsers() {
        var users = [Post]()
        do {
            users =  try JSONDecoder().decode([Post].self, from: data)
        } catch  {
            XCTFail("JSON Error: \(error)")
        }
        XCTAssert(!users.isEmpty)
    }
    
    func testCreatePosts_CreatesPosts() {
        guard let posts = try? data.createArray(ofType: Post.self) else {
            XCTFail("data.createArrayofType: Post.Self Failed")
            return
        }
        XCTAssert(!posts.isEmpty)
    }
    
    func testCreatePosts_throwsError() {
        
        var caughtError: Error? = nil
        
        do {
            _ = try Data().createArray(ofType: Post.self)
        } catch {
            caughtError = error
        }
        
        XCTAssertNotNil(caughtError)
        print(caughtError.debugDescription)
    }}
