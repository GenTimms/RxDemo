//
//  RXPostsClient.swift
//  Demo
//
//  Created by Genevieve Timms on 15/12/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RxPostsClient: RxClient {
    
    let disposeBag = DisposeBag()
    
    var sessionObservable: Observable<Data>?
    
    var postRequest = PostsEndpoints.posts.request
    var commentRequest = PostsEndpoints.comments.request
    var userRequest = PostsEndpoints.users.request
    
    lazy var postsSingle = modelData(ofType: Post.self, from: postRequest)
    lazy var commentsSingle = modelData(ofType: Comment.self, from: commentRequest)
    lazy var usersSingle = modelData(ofType: User.self, from: userRequest)
    
    func fetch(group: DispatchGroup? = nil, completion: @escaping (Result<[Post]>) -> Void) {
        
        Observable.zip(postsSingle.asObservable(), commentsSingle.asObservable(), usersSingle.asObservable()) { posts, comments, users in
            self.completePosts(posts: posts, users: users, comments: comments)
            } .subscribe(onNext: {
                completion(Result.success($0))
            }, onError: {
                completion(Result.failure($0))
                print("Error: \($0)") })
            .disposed(by: disposeBag)
    }
    
    private func completePosts(posts: [Post], users: [User], comments: [Comment]) -> [Post] {
        for post in posts {
            post.user = users.first{$0.id == post.userId}
            post.comments = comments.filter {$0.postId == post.id}
        }
        return posts
    }
    
    private func modelData<T: Codable>(ofType type: T.Type, from request: URLRequest?) -> Single<[T]> {
        return Single<[T]>.create { [sessionObservable] single in
            
            guard let request = request else {
                single(.error(RequestError.invalidRequest))
                return Disposables.create {}
            }
            
            let observableData = sessionObservable ?? URLSession.shared.rx.data(request: request)
            
            let urlSessionDisposable = observableData
                .map { try $0.createArray(ofType: type)}
                .subscribe(onNext: { single(.success($0))},
                           onError: { single(.error($0)) })
            
            return Disposables.create([urlSessionDisposable])
        }
    }
}
