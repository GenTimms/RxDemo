//
//  PostDetailViewController.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit

class PostDetailViewController: UIViewController {
    
    var post: Post?
    
    @IBOutlet weak var postDetailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let detailView = postDetailView as? PostDetailView, let post = post {
            detailView.configure(with: PostDetailViewModel(post: post))
        }
    }
}
