//
//  CDUser.swift
//  Demo
//
//  Created by Genevieve Timms on 07/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import CoreData

class CDUser: NSManagedObject {
    
    func asUser() -> User {
        return User(id: id, name: name!)
    }
    
    class func findOrCreate(from user: User, in context: NSManagedObjectContext) throws -> CDUser {
        
        //Fetch and return existing user
        let request: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", NSNumber(value: user.id))
        do {
            let existingUsers = try context.fetch(request)
            if existingUsers.count > 0 {
                guard existingUsers.count == 1 else {
                    throw CoreDataError.databaseInconsistency
                }
                return existingUsers[0]
            }
        } catch {
            throw error
        }
        
        //Create new user
        let newUser = CDUser(context: context)
        newUser.id = Int32(user.id)
        newUser.name = user.name
        
        return newUser
    }
}
