//
//  CDPost+CoreDataProperties.swift
//  Demo
//
//  Created by Genevieve Timms on 06/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//
//

import Foundation
import CoreData


extension CDPost {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPost> {
        return NSFetchRequest<CDPost>(entityName: "Post")
    }

    @NSManaged public var body: String?
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var userId: Int32
    @NSManaged public var comments: NSSet?
    @NSManaged public var user: CDUser?

}

// MARK: Generated accessors for comments
extension CDPost {

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: CDComment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: CDComment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSSet)

}
