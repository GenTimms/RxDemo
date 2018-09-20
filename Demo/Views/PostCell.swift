//
//  PostCell.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(with viewModel: PostCellViewModel) {
       titleLabel.text = viewModel.title
    }
}
