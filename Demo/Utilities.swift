//
//  Utilities.swift
//  BabylonDemo
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
                return self
            }
        }
    }
}
