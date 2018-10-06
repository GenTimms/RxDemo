//
//  PostListDataSource.swift
//  Demo
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit
import CoreData

class PostListDataSource: NSObject, UITableViewDataSource {
    
    var fetchedResultsController: NSFetchedResultsController<CDPost>
    
    init(fetchedResultsController: NSFetchedResultsController<CDPost>) {
        self.fetchedResultsController = fetchedResultsController
        super.init()
    }
    
    // MARK: - TableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
       return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        }
            return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].name
        }
            return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.postCell, for: indexPath)
        if let postCell = cell as? PostCell {
            let cdPost = fetchedResultsController.object(at: indexPath)
            postCell.configure(with: PostCellViewModel(post: cdPost.asPost()))
        }
        return cell
    }
}
