//
//  PostStorageManager.swift
//  Demo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PostStorageManager {
    
    var viewContext: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext

    init(backgroundContext: NSManagedObjectContext, viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext
    }
    
    convenience init(container: NSPersistentContainer) {
        let viewContext = container.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
        let backgroundContext = container.newBackgroundContext()
        self.init(backgroundContext: backgroundContext, viewContext: viewContext)
    }
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get shared app delegate")
        }
        self.init(container: appDelegate.persistentContainer)
    }
    
    //return a completable sequence
    func insert(_ posts: [Post], completion: @escaping (Error?) -> Void) {
        backgroundContext.performAndWait  {
            _ = try? CDPost.findOrCreate(from: posts, in: backgroundContext)
            do { try backgroundContext.save()
            } catch {
                completion(error)
            }
        }
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<CDPost> {
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController<CDPost>(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }
}

