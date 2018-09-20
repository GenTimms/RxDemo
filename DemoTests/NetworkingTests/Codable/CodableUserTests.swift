//
//  CodableUserTests.swift
//  BabylonDemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class CodableUserTests: XCTestCase {
    
    let data: Data! = {
        if let path = Bundle.main.path(forResource: "users", ofType: "json") {
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
        var users = [User]()
        do {
            users =  try JSONDecoder().decode([User].self, from: data)
        } catch  {
            XCTFail("JSON Error: \(error)")
        }
        XCTAssert(!users.isEmpty)
    }
    
    func testCreateUsers_CreatesUsers() {
        guard let users = User.createUsers(from: data) else {
            XCTFail("User.createUsers Failed")
            return
        }
        XCTAssert(!users.isEmpty)
    }
}
