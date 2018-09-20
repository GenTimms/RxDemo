//
//  CoreDataErrors.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 07/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

enum CoreDataError: Error {
    case databaseInconsistency
    case nilContainer
    case fetchRequestFailed
}
