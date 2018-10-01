//
//  MockURLSession.swift
//  DemoTests
//
//  Created by Genevieve Timms on 30/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
@testable import Demo

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
