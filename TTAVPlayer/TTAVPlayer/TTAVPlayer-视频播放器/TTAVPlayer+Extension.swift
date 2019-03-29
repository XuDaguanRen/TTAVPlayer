//
//  TTAVPlayer+Extension.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MediaPlayer

// MARK: - 顶部控制Bar 和 底部控制Bar 显示或消失动画
extension TTAVPlayer {
    
    // MARK: 顶部和底部Bar展现动画
    @objc func tt_TopAndBottomBarShow(duration: TimeInterval) -> Void {
        // 动画消失 顶部和底部控制Bar
        UIView.animate(withDuration: duration, animations: {
            
//            if self.isOrientation { //如果是全屏就响应点击事件啊
//                //显示控制器Bar
//                self.bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale * 50, width: self.frame.width, height: kScale * 50)
//                self.topBarView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: kScale * 50)
//                
//            } else {
//                self.bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale * 50, width: self.frame.width, height: kScale * 50)
//            }
            self.bottomBarView.alpha = 1.0
            self.topBarView.alpha = 1.0
            
        }) { (Bool) in
           
        }
    }
}

// MARK: - 顶部控制Bar TTTopBarDelegate  代理方法
extension TTAVPlayer {
    // MARK: 顶部更多按钮
    func tt_ClickTopBarMoreButton() {
        
    }
    // MARK: 顶部返回按钮
    func tt_ClickTopBarBackButton() {
        tt_UIInterfaceOrientation(UIInterfaceOrientation.portrait)          //默认屏幕方向
        isOrientation = false
        setupResetSubviewLayout()           //重置子视图布局
        topBarView.isHiddenTopBar = true    //隐藏顶部Bar
        avPlayerView?.ttOrientationPortraitAnimation()       //改变 playerLayer 大小
        if let vcView = ttContainerVC {
            vcView.view.addSubview(self)
        } else {
           ttContainerView?.addSubview(self)
        }
        ttPlayerOrientationPortraitAnimation()
        topBarView.isFullScreen = TTPlayTopBarType.Normal         //竖屏状态
        bottomBarView.isFullScreen = TTPlayBottomBarType.Normal   //竖屏状态
    }
}

// MARK: - 底部控制Bar TTBottomBarDelegate  代理方法
extension TTAVPlayer {
    
    // MARK: 强制横屏 通过KVC直接设置屏幕旋转方向
    func tt_UIInterfaceOrientation(_ orientation: UIInterfaceOrientation) {
        
        if orientation == UIInterfaceOrientation.landscapeRight || orientation == UIInterfaceOrientation.landscapeLeft {
            tt_OrientationSupport = TTOrientationSupport.orientationRight //左右
            UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
        } else if orientation == UIInterfaceOrientation.portrait {
            tt_OrientationSupport = TTOrientationSupport.orientationPortrait  //上下左右
            UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    // MARK: 旋转全屏动画
    func ttPlayerOrientationLeftAndRightAnimation() -> Void {
        let transformAnima = CABasicAnimation(keyPath: "transform.rotation")
        transformAnima.fromValue = -(Double.pi/2)
        transformAnima.toValue = 0
        transformAnima.duration = 0.2       //动画时间
        transformAnima.isRemovedOnCompletion = true
        transformAnima.fillMode = CAMediaTimingFillMode.forwards
        self.layer.add(transformAnima, forKey: "transform.rotation")
    }
    // MARK: 旋转竖屏动画
    func ttPlayerOrientationPortraitAnimation() -> Void {
        let transformAnima = CABasicAnimation(keyPath: "transform.rotation")
        transformAnima.fromValue = (Double.pi/2)
        transformAnima.toValue = 0
        transformAnima.duration = 0.2       //动画时间
        transformAnima.isRemovedOnCompletion = true
        transformAnima.fillMode = CAMediaTimingFillMode.forwards
        self.layer.add(transformAnima, forKey: "transform.rotation")
    }
    
     // MARK: 全屏播放
    func tt_ClickFullScreenPlayButton() {
        if !isOrientation {
            tt_UIInterfaceOrientation(UIInterfaceOrientation.landscapeRight)    //右边
            isOrientation = true
            topBarView.isHiddenTopBar = false
            setupResetSubviewLayout()       //重置子视图布局
            bottomBarView.fullScreenPlayTitle = "倍速"
            avPlayerView?.ttOrientationLeftAndRightAnimation()       //改变 playerLayer 大小
            UIApplication.shared.keyWindow?.addSubview(self)         //播放器加载到window 上
            tt_TopAndBottomBarShow(duration: 0.1)
            ttPlayerOrientationLeftAndRightAnimation()
            topBarView.isFullScreen = TTPlayTopBarType.Full             //全屏状态
            bottomBarView.isFullScreen = TTPlayBottomBarType.Full       //全屏状态
        } else {
            //如果不是全屏状态 按钮响应事件
            switch self.rate {
            case 1.0:
                bottomBarView.fullScreenPlayTitle = "x1.5"
                self.rate = 1.5
                break
            case 1.5:
                bottomBarView.fullScreenPlayTitle = "x2.0"
                self.rate = 2.0
                break
            case 2.0:
                bottomBarView.fullScreenPlayTitle = "x2.5"
                self.rate = 2.5
                break
            case 2.5:
                bottomBarView.fullScreenPlayTitle = "x0.5"
                self.rate = 0.5
                break
            case 0.5:
                bottomBarView.fullScreenPlayTitle = "正常"
                self.rate = 1.0
                break
            default:
                break
            }
        }
    }
    // MARK: 滑动结束
    ///
    /// - Parameter selider: 进度数据
    func tt_SliderDidEnd(slider: UISlider) {
        //滑块进度
        bottomBarView.value = slider.value
        //滑动结束播放
        ttAVPlayerStatus = TTAVPlayerStatus.Playing //播放
    }
    // MARK: 滑动进度条
    ///
    /// - Parameter selider: 进度数据
    func tt_SliderChanged(slider: UISlider) {
        //滑动时暂停
        ttAVPlayerStatus = TTAVPlayerStatus.Pause  //暂停
        avPlayerView?.playerSeek(slider.value + 1)       //滑动到指定位置 并播放
        // 播放了多少
        bottomBarView.playTimeValue = String(format: "%02d:%02d",(Int(slider.value) % 3600) / 60, Int(slider.value) % 60)
    }
    // MARK: 点击播放 和 暂停播放
    ///
    /// - Parameter isPlay: 是否播放 默认是播放状态
    func tt_ClickPlayButton(isPlay: Bool) {
        if ttAVPlayerStatus == TTAVPlayerStatus.Playing {
            self.ttAVPlayerStatus = TTAVPlayerStatus.Pause //暂停
        } else if ttAVPlayerStatus == TTAVPlayerStatus.Pause {
            self.ttAVPlayerStatus = TTAVPlayerStatus.Playing //播放
        } else if ttAVPlayerStatus == TTAVPlayerStatus.EndTime { 
        
        }
    }
}

// MARK: - TTAVPlayerViewDelegate 代理方法
extension TTAVPlayer {
    
    // MARK: 获取到播放状态
    func tt_PlayerStatus(playerStatus: TTPlayerStatus) {
        switch playerStatus {
        case .Failed:
            self.ttAVPlayerStatus = TTAVPlayerStatus.Failed
            break
        case .ReadyToPlay:
            self.ttAVPlayerStatus = TTAVPlayerStatus.ReadyToPlay
            break
        case .Unknown:
            self.ttAVPlayerStatus = TTAVPlayerStatus.Unknown
            break
        case .Buffering:
            self.ttAVPlayerStatus = TTAVPlayerStatus.Buffering
            break
        case .Playing:
            self.ttAVPlayerStatus = TTAVPlayerStatus.Playing
            break
        case .Pause:
            self.ttAVPlayerStatus = TTAVPlayerStatus.Pause
            break
        case .EndTime:
            self.ttAVPlayerStatus = TTAVPlayerStatus.EndTime
            break
        }
    }
    
    // MARK: 播放完成
    func tt_PlayToEndTime() {
        ttAVPlayerStatus = TTAVPlayerStatus.EndTime        //播放完成暂停播放
    }
    
    // MARK: 缓冲完成播放
    func tt_PlayBufferToComplete() {
         bottomBarView.isSelectedPlay = true
    }
    
    // MARK: 视频播放中的进度监听
    /// - Parameters:
    ///   - maximumValue: 视频总时长
    ///   - sliderValue: sliderValue 播放的进度
    ///   - playTimeValue: 已经播放时间
    ///   - endTimeValue: 视频总时间
    func tt_PeriodicTimeObserver(maximumValue: Float, sliderValue: Float, playTimeValue: String, endTimeValue: String) {
        //SliderView 数据赋值
        bottomBarView.maximumValue = maximumValue
        bottomBarView.value = sliderValue
        bottomBarView.playTimeValue = playTimeValue
        bottomBarView.endTimeValue = endTimeValue
    }
}
