//
//  Errors.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

enum RequestError: Error {
    case responseStatusCode(Int)
    case errorReturned(Error)
    case invalidResponse
    case dataNil
    case invalidRequest
    case dataEmpty
}

enum JSONError: Error {
    case parseFailed
    case noValueForKey
}



