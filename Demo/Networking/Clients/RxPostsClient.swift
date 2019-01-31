//
//  RxPostsClient2.swift
//  Demo
//
//  Created by Genevieve Timms on 09/01/2019.
//  Copyright © 2019 GMJT. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

class RxPostsClient {
    
let disposeBag = DisposeBag()
    
    var requestData : RequestData
    
    init(requestData: RequestData) {
        self.requestData = requestData
    }
    
    convenience init() {
        self.init(requestData: RequestData())
    }
    
    func fetch() -> Single<[Post]> {
        return Single<[Post]>.create { [unowned self] single in
            let zippedObservable = Observable.zip(self.modelData(ofType: Post.self).asObservable(),
                                                  self.modelData(ofType: Comment.self).asObservable(),
                                                  self.modelData(ofType: User.self).asObservable()) { posts, comments, users in
                self.completePosts(posts: posts, users: users, comments: comments)
                }
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { single(.success($0)) },
                           onError: { single(.error($0)) })
            
            return Disposables.create([zippedObservable])
        }
    }
    
    private func completePosts(posts: [Post], users: [User], comments: [Comment]) -> [Post] {
        for post in posts {
            post.user = users.first{$0.id == post.userId}
            post.comments = comments.filter {$0.postId == post.id}
        }
        return posts
    }
    
    private func modelData<T: Codable>(ofType type: T.Type) -> Single<[T]> {
        return Single<[T]>.create { [requestData] single in

            guard let observableData = requestData.sessionObservable(for: type) else {
                single(.error(RequestError.invalidRequest))
                return Disposables.create {}
            }
            
            let urlSessionDisposable = observableData
                .map { try $0.createArray(ofType: type)}
                .subscribe(onNext: { single(.success($0))},
                           onError: { single(.error($0)) })
            
            return Disposables.create([urlSessionDisposable])
        }
    }
}
