//
//  Client.swift
//  Demo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

protocol Client {
    
    var session: SessionProtocol { get set }
    
    associatedtype fetchedObject
    
    func fetch(group: DispatchGroup?, completion: @escaping (Result<[fetchedObject]>) -> Void)
    
    func fetchRequest<T: Decodable>(_ request: URLRequest, parse: @escaping (Data) throws -> T, completion: @escaping (Result<T>) -> Void)
}

extension Client {
    func jsonTask(request: URLRequest, completion: @escaping (Result<Data>) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { (data, response , error) in
            
            if let fetchError = error {
                completion(Result.failure(RequestError.errorReturned(fetchError)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(Result.failure(RequestError.invalidResponse))
                return
            }
            guard httpResponse.statusCode == 200 else {
                completion(Result.failure(RequestError.responseStatusCode(httpResponse.statusCode)))
                return
            }
            guard let data = data else {
                completion(Result.failure(RequestError.dataNil))
                return
            }
            completion(Result.success(data))
        }
        return task
    }
    
    func fetchRequest<T: Decodable>(_ request: URLRequest, parse: @escaping (Data) throws -> T, completion: @escaping (Result<T>) -> Void) {
        
        let task = jsonTask(request: request) { result in
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error): completion(Result.failure(error))
                case .success(let data):  do {
                    let parsedResult = try parse(data)
                    completion(Result.success(parsedResult))
                } catch {
                    completion(Result.failure(JSONError.parseFailed))
                    }
                }
            }
        }
        task.resume()
    }
}

protocol SessionProtocol {
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping
        (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: SessionProtocol {}
