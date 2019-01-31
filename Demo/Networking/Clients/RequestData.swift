//
//  RequestData.swift
//  Demo
//
//  Created by Genevieve Timms on 29/01/2019.
//  Copyright © 2019 GMJT. All rights reserved.
//

import Foundation
import RxSwift

struct RequestData {
    
    func sessionObservable(for type: Codable.Type) -> Observable<Data>? {
        switch type {
        case is Post.Type: return postSessionObservable
        case is Comment.Type: return commentSessionObservable
        case is User.Type: return userSessionObservable
        default: return nil
        }
    }
    
    var postRequest = PostsEndpoints.posts.request
    var commentRequest = PostsEndpoints.comments.request
    var userRequest = PostsEndpoints.users.request
    
    private var _postSessionObservable: Observable<Data>? = nil
    private var _commentSessionObservable: Observable<Data>? = nil
    private var _userSessionObservable: Observable<Data>? = nil
    
    var postSessionObservable: Observable<Data>? {
        get {
            return _postSessionObservable ?? (postRequest != nil ? URLSession.shared.rx.data(request: postRequest!) : nil)
        }
        set {
            _postSessionObservable = newValue
        }
    }
    var commentSessionObservable: Observable<Data>? {
        get {
            return _commentSessionObservable ?? (commentRequest != nil ? URLSession.shared.rx.data(request: commentRequest!) : nil)
        } set {
            _commentSessionObservable = newValue
        }
    }
    var userSessionObservable: Observable<Data>?  { get {
        return _userSessionObservable ?? (userRequest != nil ? URLSession.shared.rx.data(request: userRequest!) :  nil)    } set {
            _userSessionObservable = newValue
        }
    }
}
