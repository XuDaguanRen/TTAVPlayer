//
//  TTAVPlayer.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 播放状态枚举
@objc public enum TTAVPlayerStatus: Int {
    case Failed             //文件错误缓冲失败
    case ReadyToPlay        //准备好播放
    case Unknown            //未知错误
    case Buffering          //缓冲中
    case Playing            //正在播放
    case Pause              //暂停播放
    case EndTime            //播放完成
}

class TTAVPlayer: UIView, TTAVPlayerViewDelegate, TTBottomBarDelegate, TTTopBarDelegate {
    
    // MARK: - 属性
    /// 播放状态
    var ttAVPlayerStatus: TTAVPlayerStatus? {
        didSet {
            if ttAVPlayerStatus == TTAVPlayerStatus.Playing {     //播放状态
                //播放
                avPlayerView?.clickPlay()
                bottomBarView.isSelectedPlay = true
            } else if ttAVPlayerStatus == TTAVPlayerStatus.Pause {       //暂停状态
                //暂停
                avPlayerView?.clickPause()
                bottomBarView.isSelectedPlay = false    //修改播放按钮状态
            } else if ttAVPlayerStatus == TTAVPlayerStatus.EndTime {       //播放完成
                //暂停
                avPlayerView?.clickPause()
                bottomBarView.isSelectedPlay = false    //修改播放按钮状态
            } else if ttAVPlayerStatus == TTAVPlayerStatus.Buffering {      //正在缓冲
                
            }
        }
    }
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
        let bottomBar = TTBottomBarView.init(frame: CGRect(x: 0, y: self.frame.size.height - kScale * 50, width: self.bounds.width, height: kScale * 50), sliderHeight: kScale * 30)
        return bottomBar
    }()
    /// 是否是全屏
    var isOrientation : Bool = false
    /// 顶部Bar控制View
    lazy var topBarView: TTTopBarView = {
        let topBar = TTTopBarView.init(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: kScale * 50))
        
        return topBar
    }()
    /// 视频名称String
    var videoName: String = "" {
        didSet {
            topBarView.videoNameString = self.videoName
        }
    }
    /// 播放速度
    var rate: CGFloat = 1.0 {
        didSet {
            self.avPlayerView?.rate = self.rate
        }
    }
    /// 是否隐藏顶部Bar控制面板
    var isHiddenTopBar: Bool = false {
        didSet {
            topBarView.isHidden = isHiddenTopBar
        }
    }
    /// 是否隐藏顶部Bar控制面板
    var isHiddenTopBarBackButton: Bool = false {
        didSet { 
            topBarView.backButton?.isHidden = isHiddenTopBarBackButton
        }
    }
    /// 是否隐藏顶部Bar视频名称
    var isHiddenTopBarVideoName: Bool = false {
        didSet {
            topBarView.videoNameLable.isHidden = isHiddenTopBarVideoName
        }
    }
    /// 是否隐藏顶部Bar更多按钮
    var isHiddenTopBarMoreButton: Bool = false {
        didSet {
            topBarView.moreButton?.isHidden = isHiddenTopBarMoreButton
        }
    }
    /// 是否隐藏底部部Bar控制面板
    var isHiddenbottomBarBar: Bool = false {
        didSet {    //竖屏默认隐藏
            bottomBarView.isHidden = isHiddenbottomBarBar
        }
    }
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
    
    // MARK: 重置子视图布局
    func setupResetSubviewLayout() -> Void {
        self.removeFromSuperview()
        if isOrientation { //横屏状态
            self.frame = (UIApplication.shared.keyWindow?.bounds)!
            avPlayerView?.frame = self.frame
            bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale*65, width: self.frame.width, height: kScale*65)
            topBarView.frame = CGRect(x: 0, y: 0, width:  self.frame.width, height: kScale*65)
            
        } else { //竖屏状态
            self.frame = ttFrame!
            avPlayerView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale*50, width: self.frame.width, height: kScale*50)
            topBarView.frame = CGRect(x: 0, y: 0, width:  self.frame.width, height: kScale*50)
        }
        
        self.layoutIfNeeded()
    }
    
    // MARK: 布局顶部控制BarView
    func setupTopBarView() -> Void {
        topBarView.delegate = self
        topBarView.backgroundColor = UIColor.clear
        self.addSubview(topBarView)
    }
    
    // MARK: 布局底部播放控制View按钮SliderView
    fileprivate func setupBottomBarView() -> Void {
        //底部播放 暂定 快进 全屏播放工具条
        bottomBarView.delegate = self
        bottomBarView.backgroundColor = UIColor.clear
        self.addSubview(bottomBarView)
    }
    
    // MARK: 布局AVPlayer播放器
    fileprivate func setupAVPlayer() -> Void {
        
        //视频播放器
        avPlayerView?.delegate = self    //设置代理
        self.addSubview(avPlayerView!)
        
    }
    
    // MARK: - 布局TTAVPlayerUI
    fileprivate func setupTTAVPlayerUI() -> Void {
        
        setupAVPlayer()
        setupBottomBarView()
        setupTopBarView()
    }
    
}

