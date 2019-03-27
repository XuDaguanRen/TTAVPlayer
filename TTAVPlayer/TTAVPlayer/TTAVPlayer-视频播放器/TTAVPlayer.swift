//
//  TTAVPlayer.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTAVPlayer: UIView {
    
    /// 记录初始大小
    var ttFrame: CGRect?
    /// 记录父视图 视频全屏播放后返回初始播放
    var ttContainerView: UIView?
    /// 记录父视图 视频全屏播放后返回初始播放
    var ttContainerVC: UIViewController?
    
     // MARK: - 初始化配置
    ///
    /// - Parameters:
    ///   - frame: 大小
    ///   - containerVC: 添加播放器的控制器 便于隐藏系统音量UI
    ///   - containerView: 添加播放器的控制器View 如果传入了控制器，containerView不生效
    init(frame: CGRect, _ containerVC: UIViewController?, _ containerView: UIView?) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        ttContainerVC = containerVC
        ttContainerView = containerView
        ttFrame = frame
        
        setupTTAVPlayerUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    // MARK: - 布局TTAVPlayerUI
   fileprivate func setupTTAVPlayerUI() -> Void {
        
    }
    
}

