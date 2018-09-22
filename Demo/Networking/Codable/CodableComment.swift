//
//  CodableComment.swift
//  Demo
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

extension Comment {
    
    static func createComments(from json: Data) -> [Comment]? {
        if let comments = try? JSONDecoder().decode([Comment].self, from: json) {
            return comments
        } else {
            return nil
        }
    }
    
    static func createJSON(from comments: [Comment]) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(comments)
    }
}
