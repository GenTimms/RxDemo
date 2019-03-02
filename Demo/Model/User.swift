//
//  User.swift
//  Demo
//
//  Created by Genevieve Timms on 07/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class User: Codable {
    
    let id: Int32
    let name: String
    
    init(id: Int32, name: String) {
        self.id = id
        self.name = name
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
