//
//  CDUser+CoreDataProperties.swift
//  Demo
//
//  Created by Genevieve Timms on 06/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//
//

import Foundation
import CoreData


extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "User")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var posts: NSSet?

}

// MARK: Generated accessors for posts
extension CDUser {

    @objc(addPostsObject:)
    @NSManaged public func addToPosts(_ value: CDPost)

    @objc(removePostsObject:)
    @NSManaged public func removeFromPosts(_ value: CDPost)

    @objc(addPosts:)
    @NSManaged public func addToPosts(_ values: NSSet)

    @objc(removePosts:)
    @NSManaged public func removeFromPosts(_ values: NSSet)

}
