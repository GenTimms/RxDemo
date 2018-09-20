//
//  UsersOperation.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class UsersOperation: Operation {
    
    let client: DemoClient
    
    init(client: DemoClient) {
        self.client = client
        super.init()
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _finished = false
    override private(set) var isFinished: Bool {
        get {
            return _finished
        }
        
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    private var _executing = false
    override private(set) var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override func start() {
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
        
        client.fetchUsers { result in
            switch result {
            case .success(let users):
                self.isExecuting = false
                self.isFinished = true
                self.client.users = users
            case .failure(let error):
                self.client.userFetchingError = error
                self.isExecuting = false
                self.isFinished = true
            }
        }
    }
}
