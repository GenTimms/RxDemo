//
//  PostDetailView.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 10/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit

class PostDetailView: UIView {

    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    func configure(with viewModel: PostDetailViewModel) {
        bodyLabel.text = viewModel.body
        userLabel.text = viewModel.user
        commentCountLabel.text = viewModel.commentCount
    }
}
