//
//  Alert.swift
//  Demo
//
//  Created by Genevieve Timms on 05/03/2019.
//  Copyright © 2019 GMJT. All rights reserved.
//

import Foundation

class Alert {
    
    let title: String
    let message: String
    
    let error: Error?
    
    init(title: String = "Error", message: String = " ", error: Error? = nil) {
        self.title = title
        self.message = message
        self.error = error
    }
}
