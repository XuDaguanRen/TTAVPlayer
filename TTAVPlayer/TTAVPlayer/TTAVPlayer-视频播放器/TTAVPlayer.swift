//
//  TTAVPlayer.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTAVPlayer: UIView, TTAVPlayerViewDelegate {

    /// 记录初始大小
    var ttFrame: CGRect? 
    /// 记录父视图 视频全屏播放后返回初始播放
    var ttContainerView: UIView?
    /// 记录父视图 视频全屏播放后返回初始播放
    var ttContainerVC: UIViewController?
    /// 播放器
    lazy var avPlayerView: TTAVPlayerView? = {
        let avPlayer = TTAVPlayerView.init(frame: self.bounds)
        avPlayer.backgroundColor = UIColor.black
        return avPlayer
    }()
    /// 播放文件路径
    var urlString: String = "" {
        didSet {
            if !urlString.isEmpty {
                avPlayerView?.urlString = urlString   //传递视频路径直接播放了，外部调用直接传路径就好了
            }
        }
    }
    /// 底部Bar 使用
    lazy var bottomBarView: TTBottomBarView = {
        //底部播放 暂定 快进 全屏播放工具条
        let bottomBar = TTBottomBarView.init(frame: CGRect(x: 0, y: self.frame.size.height - kScale * 56, width: self.bounds.width, height: kScale * 56), sliderHeight: kScale * 35)
        bottomBar.layer.masksToBounds = true
        bottomBar.layer.cornerRadius = 2.0
        return bottomBar
    }()
    
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
    
    // MARK: 布局底部播放控制View按钮SliderView
    func setupBottomBarView() -> Void {
        //底部播放 暂定 快进 全屏播放工具条
        bottomBarView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.addSubview(bottomBarView)
    }
    
    // MARK: 布局AVPlayer播放器
    func setupAVPlayer() -> Void {
        
        //视频播放器
        avPlayerView?.delegate = self    //设置代理
        self.addSubview(avPlayerView!)
        
    }
    
    // MARK: - 布局TTAVPlayerUI
    fileprivate func setupTTAVPlayerUI() -> Void {
        
        setupAVPlayer()
        setupBottomBarView()
        
    }
    
}

