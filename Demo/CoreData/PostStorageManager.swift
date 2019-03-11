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
import RxSwift

class PostStorageManager {
    
    var viewContext: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext
    
    //MARK: - Initialisation
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
    
    //MARK: - Fetch
    private let fetchRequest: NSFetchRequest<CDPost> = {
        let request: NSFetchRequest<CDPost> = CDPost.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        return request
    }()
    
    func fetch() -> Single<[Post]>  {
        return Single<[Post]>.create { single in
            do {
                let posts = try self.viewContext.fetch(self.fetchRequest).map { $0.asPost() }
                single(.success(posts))
            } catch {
                single(.error(error))
            }
            return Disposables.create { }
        }
    }
    
    //MARK: - Insert
    func rxInsert(_ posts: [Post]) -> Completable {
        return Completable.create { completable in
            let disposable = Disposables.create {}
            self.backgroundContext.perform { //AndWait
                print("BackgroundContext Thread: \(Thread.current)")
                do {
                    try CDPost.findOrCreate(from: posts, in: self.backgroundContext)
                    try self.backgroundContext.save()
                    completable(.completed)
                    //posts.onNext?
                } catch {
                    completable(.error(error))
                }
            }
            return disposable
        }
    }
}

