//
//  RxClient.swift
//  Demo
//
//  Created by Genevieve Timms on 30/12/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
import RxSwift


protocol RxClient {
    
    associatedtype fetchedObject
    
    var sessionObservable: Observable<Data>? { get set }
    
    func fetch() -> Single<[fetchedObject]>
    
}
