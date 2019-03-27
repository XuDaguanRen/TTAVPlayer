//
//  TTHomeController.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/26.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTHomeController: TTBaseController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ttTitleString = "首页"
        
        setupHomeUI()
    }
    
   fileprivate func setupHomeUI() -> Void {
    //1.从mainBundle获取test.mp4的具体路径
    //        let paths: String? = "https://lymanli-1258009115.cos.ap-guangzhou.myqcloud.com/video/sample/sample-video2.mp4"
    //        let paths = Bundle.main.path(forResource: "01-课程安排", ofType: "mp4")
    //        path =  "///var/containers/Bundle/Application/A9B82066-0405-484D-8BF0-64BC438B0D4A/Touch.app/01-%E8%AF%BE%E7%A8%8B%E5%AE%89%E6%8E%92.mp4"
//    let videoName = "01-课程安排.mp4"
    
    let path = Bundle.main.path(forResource: "01-课程安排", ofType: "mp4")
    
    let ttPlayer = TTAVPlayerView.init(frame: CGRect(x: 0, y: 80, width: kScreemWidth, height: 180))
    ttPlayer.urlString = path!
    
    view.addSubview(ttPlayer)
    
    }
}
