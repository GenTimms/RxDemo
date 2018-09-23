//
//  Created by Genevieve Timms on 23/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation

class CommentsClient: Client {

    var session: SessionProtocol = URLSession.shared
    
    func fetch(group: DispatchGroup? = nil, completion: @escaping (Result<[Comment]>) -> Void) {
        fetchComments(group: group, completion: completion)
    }
    
    func fetchComments(group: DispatchGroup?, completion: @escaping (Result<[Comment]>) -> Void) {
        group?.enter()
        guard let request = PostsEndpoints.comments.request else {
            completion(Result.failure(RequestError.invalidRequest))
            return
        }
        
        fetchRequest(request, parse: { (data) -> [Comment]? in
            if let comments = Comment.createComments(from: data) {
                return comments
            } else {
                return nil
            }
        }, completion: { result in
            completion(result)
            group?.leave()
        })
    }
}
