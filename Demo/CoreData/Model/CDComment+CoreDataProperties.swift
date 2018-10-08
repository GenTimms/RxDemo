//
//  CDComment+CoreDataProperties.swift
//  Demo
//
//  Created by Genevieve Timms on 06/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//
//

import Foundation
import CoreData


extension CDComment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDComment> {
        return NSFetchRequest<CDComment>(entityName: "Comment")
    }

    @NSManaged public var body: String?
    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var postId: Int32
    @NSManaged public var post: CDPost?

}
