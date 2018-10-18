//
//  Utilities.swift
//  Demo
//
//  Created by Genevieve Timms on 08/09/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var contents: UIViewController? {
        get {
            if let navCon = self as? UINavigationController {
                return navCon.visibleViewController ?? self
            } else {
                if let splitView = self as? UISplitViewController {
                    return splitView.viewControllers[0].contents
                } else {
                    return self
                }
            }
        }
    }
}

extension Data {
    func getJSONValue(for key: String) -> String? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: []) as? [String: AnyObject]
            guard let jsonData = json, let value = jsonData[key] as? String else {
                throw JSONError.parseFailed
            }
            return  value
        }
        catch {
            return nil
        }
    }
}

