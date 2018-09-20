//
//  CodableUser.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

extension User {
    
    static func createUsers(from json: Data) -> [User]? {
        if let users = try? JSONDecoder().decode([User].self, from: json) {
            return users
        } else {
            return nil
        }
    }
    
    static func createJSON(from users: [User]) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(users)
    }
}
