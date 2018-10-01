//
//  ClientTests.swift
//  DemoTests
//
//  Created by Genevieve Timms on 30/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import Demo

class ClientTests: XCTestCase {
    
    let jsonData = "{\"name\": \"Genevieve Timms\"}".data(using: .utf8)
    let request = URLRequest(url: URL(string: "http://fakeURL.com")!)
    let response =  HTTPURLResponse(url: URL(string: "http://fakeURL.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
    
    class MockClient: Client {
        var session: SessionProtocol = MockURLSession(data: nil, urlResponse: nil, error: nil)
        
        func fetch(group: DispatchGroup? = nil, completion: @escaping (Result<[String]>) -> Void) {
        }
    }
    
    var client: MockClient!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        client = MockClient()
        mockURLSession = MockURLSession(data: nil, urlResponse: nil, error: nil)
        client.session = mockURLSession
    }
    
    //MARK: - Data Return
    func testFetchRequest_returnsParsedData() {
        mockURLSession = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        client.session = mockURLSession
        
        var parsedData: String? = nil
        let resultExpectation = expectation(description: "Result")
        
        client.fetchRequest(request, parse: {$0.getJSONValue(for: "name")}) { result in
            switch result {
            case .failure(let error): XCTFail("Fetch Users Failed. Error: \(error)")
            case .success(let result): parsedData = result; resultExpectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(parsedData, "Genevieve Timms")
        }
    }
    
    //MARK: - Parse Error Return
    func testFetchRequest_withInvalidParse_ReturnsParseFailedError() {
        mockURLSession = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        client.session = mockURLSession
        
        var caughtError: Error? = nil
        let resultExpectation = expectation(description: "Result")
        
        client.fetchRequest(request, parse: {$0.getJSONValue(for: "invalidKey")}) { result in
            switch result {
            case .failure(let error): caughtError = error; resultExpectation.fulfill()
            case .success(let result): XCTFail("Fetch Users Succeeded. Result: \(result)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            XCTAssertEqual(caughtError as? JSONError, JSONError.parseFailed)
        }
    }
    
    //MARK: - Data Task Error Return
    //Data Task Returns Error
    func testFetchRequest_withDataTaskError_ReturnsError() {
        
        let error = NSError(domain: "SomeError", code: 1234, userInfo: nil)
        
        mockURLSession = MockURLSession(data: jsonData, urlResponse: response, error: error)
        client.session = mockURLSession
        
        var caughtError: Error? = nil
        let resultExpectation = expectation(description: "Result")
        
        client.fetchRequest(request, parse: {$0.getJSONValue(for: "name")}) { result in
            switch result {
            case .failure(let error): caughtError = error; resultExpectation.fulfill()
            case .success(let result): XCTFail("Fetch Users Succeeded. Result: \(result)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            guard let requestError = caughtError as? RequestError else {
                XCTFail("Error is not fetchError: \(caughtError.debugDescription)")
                return
            }
            switch requestError {
            case .errorReturned(let returnedError): XCTAssertEqual(returnedError as NSError, error)
            default: XCTFail("Incorrect requestError returned \(requestError)")
            }
        }
    }
    
    //Nil Response Returns Error
    func testFetchRequest_withNilResponse_ReturnsInvalidResponseError() {
        
        mockURLSession = MockURLSession(data: jsonData, urlResponse: nil, error: nil)
        client.session = mockURLSession
        
        var caughtError: Error? = nil
        let resultExpectation = expectation(description: "Result")
        
        client.fetchRequest(request, parse: {$0.getJSONValue(for: "name")}) { result in
            switch result {
            case .failure(let error): caughtError = error; resultExpectation.fulfill()
            case .success(let result): XCTFail("Fetch Users Succeeded. Result: \(result)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            guard let requestError = caughtError as? RequestError else {
                XCTFail("Error is not fetchError: \(caughtError.debugDescription)")
                return
            }
            
            switch requestError {
            case .invalidResponse: XCTAssertTrue(true)
            default: XCTFail("Incorrect requestError returned: \(requestError)")
            }
        }
    }
    
    //Invalid Response Returns Error
    func testFetchRequest_withInvalidResponse_ReturnsInvalidResponseDataCodeError() {
        
        let response =  HTTPURLResponse(url: URL(string: "http://fakeURL.com")!, statusCode: 400, httpVersion: nil, headerFields: nil)
        mockURLSession = MockURLSession(data: jsonData, urlResponse: response, error: nil)
        client.session = mockURLSession
        
        var caughtError: Error? = nil
        let resultExpectation = expectation(description: "Result")
        
        client.fetchRequest(request, parse: {$0.getJSONValue(for: "name")}) { result in
            switch result {
            case .failure(let error): caughtError = error; resultExpectation.fulfill()
            case .success(let result): XCTFail("Fetch Users Succeeded. Result: \(result)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            guard let requestError = caughtError as? RequestError else {
                XCTFail("Error is not fetchError: \(caughtError.debugDescription)")
                return
            }
            
            switch requestError {
            case .responseStatusCode(let code): XCTAssertEqual(code, 400)
            default: XCTFail("Incorrect requestError returned: \(requestError)")
            }
        }
    }
    
    //Data nil Returns Error
    func testFetchRequest_withNilData_ReturnsDataNilError() {
        
        mockURLSession = MockURLSession(data: nil, urlResponse: response, error: nil)
        client.session = mockURLSession
        
        var caughtError: Error? = nil
        let resultExpectation = expectation(description: "Result")
        
        client.fetchRequest(request, parse: {$0.getJSONValue(for: "name")}) { result in
            switch result {
            case .failure(let error): caughtError = error; resultExpectation.fulfill()
            case .success(let result): XCTFail("Fetch Users Succeeded. Result: \(result)")
            }
        }
        
        waitForExpectations(timeout: 1) { _ in
            guard let requestError = caughtError as? RequestError else {
                XCTFail("Error is not fetchError: \(caughtError.debugDescription)")
                return
            }
            
            switch requestError {
            case .dataNil: XCTAssertTrue(true)
            default: XCTFail("Incorrect requestError returned: \(requestError)")
            }
        }
    }
}








