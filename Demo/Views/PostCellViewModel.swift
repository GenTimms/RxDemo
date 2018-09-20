//
//  PostCellViewModel.swift
//  BabylonDemo
//
//  Created by Genevieve Timms on 09/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

struct PostCellViewModel {
    let title: String
}

extension PostCellViewModel {
    init(post: Post) {
        title = post.title
    }
}
