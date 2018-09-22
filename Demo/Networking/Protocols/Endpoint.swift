//
//  Endpoint.swift
//  Demo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

import Foundation

protocol Endpoint {
    var base: String { get }
    var path: String { get }
}

extension Endpoint {
    var request: URLRequest? {
        if let url = url {
            return URLRequest(url: url)
        } else {
            return nil
        }
    }
    
    var url: URL? {
        return urlComponents?.url ?? nil
    }
    
    var urlComponents: URLComponents? {
        guard var components = URLComponents(string: base) else {
            return nil
        }
        components.path = path
        return components
    }
}

