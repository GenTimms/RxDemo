//
//  ClientData.swift
//  DemoTests
//
//  Created by Genevieve Timms on 19/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

struct ClientData {
    
    static let error = NSError(domain: "SomeError", code: 1234, userInfo: nil)
    
    static let response =  HTTPURLResponse(url: URL(string: "http://jsonplaceholder.typicode.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    
    static let postData: Data! = {
        if let path = Bundle.main.path(forResource: "posts", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    static let commentData: Data! = {
        if let path = Bundle.main.path(forResource: "comments", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    static let userData: Data! = {
        if let path = Bundle.main.path(forResource: "users", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    static let fakeData = "{\"name\": \"Genevieve Timms\"}".data(using: .utf8)
    
}
