//
//  TTNavigationController.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/26.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTNavgationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isHidden = true
        self.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if children.count > 0 {
          viewController.hidesBottomBarWhenPushed = true
        }
        
        self.interactivePopGestureRecognizer?.isEnabled = true
        super.pushViewController(viewController, animated: animated)
    }
}
