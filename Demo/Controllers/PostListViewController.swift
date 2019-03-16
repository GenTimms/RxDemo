//
//  PostListTableViewController.swift
//  Demo
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit
import CoreData
import RxSwift
import RxCocoa

class PostListViewController: UIViewController, UISplitViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: PostViewModel! { didSet { bindViewModel() }}
    let disposeBag = DisposeBag()
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        bindViewModel()
    }
    
    private func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        tableView.separatorInset = .zero
    }
    
    //MARK: - Binding to viewModel
    func bindViewModel() {
        if tableView != nil && viewModel != nil {
            print("Binding")
            bindTableView()
            bindAlerts()
        }
    }
    
    private func bindAlerts() {
        viewModel.alerts.asObserver().subscribe(onNext: {
            self.displayAlert($0)
        })
            .disposed(by: disposeBag)
    }
    
    private func bindTableView() {
        viewModel.data.drive(tableView.rx.items(cellIdentifier: Cells.postCell, cellType: PostCell.self)) { (_, post, cell) in
            cell.configure(with: PostCellViewModel(post: post))
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Post.self)
            .subscribe(onNext: {
                self.performSegue(withIdentifier: Segues.detailSegue, sender: $0)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Error Handling
    private func displayAlert(_ alert: Alert) {
        let details = alert.message + " " + ((alert.error?.localizedDescription) ?? "")
        print(details)
        let alert = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.detailSegue {
            if let postDetailVC = segue.destination.contents as? PostDetailViewController, let post = sender as? Post  {
                postDetailVC.post = post
                collapseDetailViewController = false
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

