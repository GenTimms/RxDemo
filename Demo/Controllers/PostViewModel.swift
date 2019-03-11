//
//  PostViewModel.swift
//  Demo
//
//  Created by Genevieve Timms on 28/01/2019.
//  Copyright © 2019 GMJT. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PostViewModel {
    
    let disposeBag = DisposeBag()
    
    var client: RxPostsClient
    var storageManager: PostStorageManager

    init(client: RxPostsClient? = nil, storageManager: PostStorageManager? = nil) {
        self.client = client ?? RxPostsClient()
        self.storageManager = storageManager ?? PostStorageManager()
        
        self.networkData
            .subscribe(onNext: { posts in
                storageManager?.rxInsert(posts)
                                .debug()
                                .observeOn(MainScheduler.instance)
                                .subscribe(onError: {self.alerts.onNext(Alert(title: "Database Error", message: "Could not insert posts into database", error: $0))})
                    .disposed(by: self.disposeBag)
            })
        .disposed(by: disposeBag)
    }
    
    func refreshData() {
        refresh.onNext(())
        print("Refreshing")
    }
    
    let refresh = PublishSubject<Void>()
    let alerts = PublishSubject<Alert>()
    
    lazy var data: Driver<[Post]> = {
        return self.networkData.asDriver { error in
            self.alerts.onNext(Alert(title: "Network Error", message: "Could not fetch from network", error: error))
            return self.databaseData.asDriver { error in
                self.alerts.onNext(Alert(title: "Database Error", message: "Could not fetch from database", error: error))
                return Driver.just([])
            }.debug()
        }
    }()
    
    lazy var networkData: Observable<[Post]> = {
        return self.refresh.asObservable()
            .debug()
            .throttle(3, scheduler: MainScheduler.instance)
            .flatMapLatest(client.fetch).asObservable()
            .share() 
    }()
    
    lazy var databaseData: Observable<[Post]> = {
        return storageManager.fetch().asObservable()
                    .debug()
    }()
}
