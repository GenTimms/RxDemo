//
//  Result.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation


import Foundation

enum Result<T> {
    case success(T)
    case failure(Error)
}
