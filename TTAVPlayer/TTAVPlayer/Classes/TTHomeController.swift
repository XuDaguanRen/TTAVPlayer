//
//  TTHomeController.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/26.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTHomeController: TTBaseController, TTAVPlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ttTitleString = "首页"
        
        setupHomeUI()
    }
    
    @objc func clickBut() -> Void {
        
        self.present(TTTestViewController(), animated: false) {
            
        }
       
    }
    
    func tt_avPlayerLockScreenPreviousTrack() {
        TTLog("上一首")
    }
    
    func tt_avPlayerLockScreenNextTrack() {
        TTLog("下一首")
    }

   fileprivate func setupHomeUI() -> Void {
    //1.从mainBundle获取test.mp4的具体路径
    //        let paths: String? = "https://lymanli-1258009115.cos.ap-guangzhou.myqcloud.com/video/sample/sample-video2.mp4"
    //        let paths = Bundle.main.path(forResource: "01-课程安排", ofType: "mp4")
    //        path =  "///var/containers/Bundle/Application/A9B82066-0405-484D-8BF0-64BC438B0D4A/Touch.app/01-%E8%AF%BE%E7%A8%8B%E5%AE%89%E6%8E%92.mp4"
//    let videoName = "01-课程安排.mp4"
    
//    let path = Bundle.main.path(forResource: "01-课程安排", ofType: "mp4")
    
//    let ttPlayer = TTAVPlayer.init(frame: CGRect(x: 0, y: 80, width: kScreemWidth, height: 180))
//    let ttPlayer = TTAVPlayer.init(frame: CGRect(x: 0, y: 80, width: kScreemWidth, height: 180), self, nil)
//    ttPlayer.urlString = path!
//    ttPlayer.videoName = "01-课程安排"
//    ttPlayer.isHiddenTopBar = true
////    ttPlayer.isHiddenTopBarMoreButton = true
////    ttPlayer.isHiddenTopBarVideoName = true
//    ttPlayer.isPlayingInBackground = true
//    ttPlayer.delegate = self
//
//    view.addSubview(ttPlayer)
    
    let but = UIButton(frame: CGRect(x: 150, y: 320, width: kScale * 90, height: kScale * 55))
    
    but.setTitle("下一页", for: .normal)
    but.addTarget(self, action: #selector(clickBut), for: .touchUpInside)
    but.backgroundColor = UIColor.red
    view.addSubview(but)
    
    }
}


