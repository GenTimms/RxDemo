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
    
    var persistentContainer: NSPersistentContainer!

    init(container: NSPersistentContainer) {
        self.persistentContainer = container
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    convenience init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can not get shared app delegate")
        }
        self.init(container: appDelegate.persistentContainer)
    }
    
    func insert(_ posts: [Post], completion: @escaping (Error?) -> Void) {
        let context = persistentContainer.newBackgroundContext()
        
        context.performAndWait  {
            _ = try? CDPost.findOrCreate(from: posts, in: context)
            do { try context.save()
            } catch {
                completion(error)
            }
        }
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<CDPost> {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController<CDPost>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }
}

