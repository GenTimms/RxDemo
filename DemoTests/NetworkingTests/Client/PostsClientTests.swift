//
//  PostsClientTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class PostsClientTests: XCTestCase {
    
    var sut: PostsClient!
    var mockURLSession: MockURLSession!
    
    let response =  HTTPURLResponse(url: URL(string: "http://jsonplaceholder.typicode.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    
    //MARK: - Mock Data To Return
    let postData: Data! = {
        if let path = Bundle.main.path(forResource: "users", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    let commentData: Data! = {
        if let path = Bundle.main.path(forResource: "comments", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    let userData: Data! = {
        if let path = Bundle.main.path(forResource: "users", ofType: "json") {
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        }
        return nil
    }()
    
    override func setUp() {
        super.setUp()
        sut = PostsClient()
        mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        sut.session = mockURLSession
    }
    
    //TODO:- Implement Client Tests Using MockURLSession
}

//MARK: - MockURLSession & MockTask
extension PostsClientTests {
    
    class MockTask: URLSessionDataTask {
        private let data: Data?
        private let urlResponse: URLResponse?
        private let responseError: Error?
        
        typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
        var completionHandler: CompletionHandler?
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            self.data = data
            self.urlResponse = urlResponse
            self.responseError = error
        }
        
        override func resume() {
            DispatchQueue.main.async() {
                self.completionHandler?(self.data, self.urlResponse, self.responseError)
            }
        }
    }
    
    class MockURLSession: SessionProtocol {
        var url: URL?
        private let dataTask: MockTask
        
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            dataTask = MockTask(data: data, urlResponse: urlResponse, error: error)
        }
        
        func dataTask(
            with request: URLRequest,
            completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            self.url = request.url
            dataTask.completionHandler = completionHandler
            return dataTask
        }
    }
}
