//
//  TTMainTabBar.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/26.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTMainTabBar: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildControllers()
    }
    
    fileprivate  func addController(dict:[String : String]) -> UIViewController {
        //守护是否有值
        let namespace = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? ""
        guard let clsName = dict["clsName"],
            let title = dict["title"],
            let imgName = dict["imgName"],
            let cls = NSClassFromString(namespace + "." + clsName) as? UIViewController.Type
            else {
                return UIViewController()
        }
        
        let vc = cls.init()
        vc.title = title
        vc.tabBarItem.image = UIImage(named: imgName)
        vc.tabBarItem.selectedImage = UIImage(named: imgName + "_sel")?.withRenderingMode(.alwaysOriginal)
        
        return TTNavigationController(rootViewController: vc)
    }
    
    fileprivate func setupChildControllers() -> Void {
        let barArray = [
            ["clsName" : "TTHomeController", "title" : "视频", "imgName" : "dd_bar_home"], //dd_bar_home
            ["clsName" : "TTMyController", "title" : "我的", "imgName" : "dd_bar_my"], //dd_bar_my
        ]
        
        //创建控制数组
        var barArrayM = [UIViewController]()
        
        for vcDict in barArray {
            barArrayM.append(addController(dict: vcDict))
        }
        
        viewControllers = barArrayM
    }
}
