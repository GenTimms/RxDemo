//
//  DemoClientTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class DemoClientTests: XCTestCase {
    
    var sut: DemoClient!
    var mockURLSession: MockURLSession!
    
    let response =  HTTPURLResponse(url: URL(string: "http://jsonplaceholder.typicode.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    
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
        sut = DemoClient()
        mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        sut.session = mockURLSession
    }
    
    //MARK: - DATA RETURN
    func test_fetchUsers_WhenSuccessful_CreatesUsers() {
        
        guard let data = userData else {
            XCTFail("Can't get JSON Data")
            return
        }
        
        mockURLSession = MockURLSession(data: data, urlResponse: response, error: nil)
        sut.session = mockURLSession
        let usersExpectation = expectation(description: "Users")
        var users: [User]? = nil
        
        sut.fetchUsers { result in
            switch result {
            case .success(let fetchedUsers): users = fetchedUsers; usersExpectation.fulfill()
            case .failure(let error): XCTFail("Fetch Users Failed. Error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 1) {_ in
            XCTAssertEqual(users?.count, 10)
        }
    }
    
    //MARK: - ERROR RETURN
    func test_fetchUsers_WhenJSONIsInvalid_ReturnsError() {
        mockURLSession = MockURLSession(data: Data(), urlResponse: nil, error: nil)
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        sut.fetchUsers { result in
            switch result {
            case .success: XCTFail("Invalid JSON didn't return Error")
            case .failure(let error): catchedError = error; errorExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(catchedError)
        }
    }
    
    func test_fetchUsers_WhenDataIsNil_ReturnsError() {
        mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        
        sut.fetchUsers { result in
            switch result {
            case .success: XCTFail("Invalid JSON didn't return Error")
            case .failure(let error): catchedError = error; errorExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 1) {(error) in
            XCTAssertNotNil(catchedError)
        }
    }
    
    func test_fetchUsers_WhenResponseHasError_ReturnsError() {
        
        let error = NSError(domain: "SomeError", code: 1234, userInfo: nil)
        
        guard let data = userData else {
            XCTFail("Can't get JSON Data")
            return
        }
        
        mockURLSession = MockURLSession(data: data, urlResponse: nil, error: error)
        sut.session = mockURLSession
        
        let errorExpectation = expectation(description: "Error")
        var catchedError: Error? = nil
        
        sut.fetchUsers { result in
            switch result {
            case .success: XCTFail("Invalid JSON didn't return Error")
            case .failure(let error): catchedError = error; errorExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { (error) in
            XCTAssertNotNil(catchedError)
        }
    }
}

//MARK: - MOCK URL SESSION & TASK
extension DemoClientTests {
    
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
