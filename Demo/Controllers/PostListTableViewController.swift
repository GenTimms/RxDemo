//
//  PostListTableViewController.swift
//  Demo
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit
import CoreData

class PostListTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    var client: PostsClient?
    var storageManager: PostStorageManager?
    var dataProvider: PostDataProvider?
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorInset = .zero
    }
    
    //MARK: - Fetching
    func initiateFetch() {
        guard let _ = client, let storageManager = storageManager else {
            return
        }
        
        if dataProvider == nil {
            dataProvider = PostDataProvider(storageManager: storageManager)
        }
        
        tableView.dataSource = dataProvider?.dataSource
        fetchPosts()
    }
    
    private func fetchPosts() {
        if let client = client {
            client.fetch { (result) in
                switch result {
                case.success(let fetchedPosts): self.storageManager?.insert(fetchedPosts) { error in
                    self.displayErrorNotification(description: "Database Update Error", error: error)
                    }
                case.failure(let error):
                    self.displayErrorNotification(description: "Network Fetch Error", error: error)
                    return
                }
                self.updateUI()
            }
        }
    }
    
    private func updateUI()  {
        dataProvider?.fetchData { error in
            if let error = error {
                displayErrorNotification(description: "Data Provider Fetch Error", error: error)
                return
            }
            tableView.reloadData()
        }
    }
    
    //MARK: - Error Handling
    private func displayErrorNotification(description: String, error: Error?) {
        let details = description + " " + ((error?.localizedDescription) ?? "")
        print(details)
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segues.detailSegue, sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.detailSegue {
            if let postDetailVC = segue.destination.contents as? PostDetailViewController {
                if let indexPath = sender as? IndexPath {
                    postDetailVC.post = dataProvider?.objectAt(indexPath: indexPath)
                    collapseDetailViewController = false
                }
            }
        }
    }
    
    //MARK: - SplitViewControllerDelegate
    private var collapseDetailViewController = true
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseDetailViewController
    }
}

