//
//  PostDataProvider.swift
//  Demo
//
//  Created by Genevieve Timms on 21/10/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
import CoreData

class PostDataProvider {
    
    private var storageManager: PostStorageManager
    
    lazy var fetchedResultsController = storageManager.createFetchedResultsController()
    
    lazy var dataSource = PostListDataSource(fetchedResultsController: fetchedResultsController)
    
    init(storageManager: PostStorageManager) {
        self.storageManager = storageManager
    }
    
    func objectAt(indexPath: IndexPath) -> Post {
        return fetchedResultsController.object(at: indexPath).asPost()
    }
    
    func fetchData(completion: (Error?) -> Void) {
        do { try fetchedResultsController.performFetch()
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
