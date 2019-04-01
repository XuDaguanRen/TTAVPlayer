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

// MARK: - 监听按键音量变化
extension TTAVPlayer {
    
    // MARK: 删除音量通知 上面已经有了一个删除当前View 的所有通知了 这个不用调用
    func removeOutputVolume() {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume", context: nil)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    // MARK: 监听手机侧键音量变化
    func volumeChangesListener() -> Void {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
//            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker) //设置扬声器输出
        } catch _ {
            
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        AVAudioSession.sharedInstance().addObserver(self, forKeyPath: "outputVolume", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.new.rawValue | NSKeyValueObservingOptions.old.rawValue), context: nil)
    }
    
    // MARK: 获取到监听的音量变化数据
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        weak var weakSelf = self
        guard let newChange = change else {
            return
        }
        let movedValue = newChange[.newKey] as! Float
        if !weakSelf!.subviews.contains(weakSelf!.volumeSlider) {
            // 调用系统的布局屁用没有  自定义的可以修改  可以和下面的亮度那样封装下
            weakSelf!.volumeSlider.alpha = 1
            if let containerVC = ttContainerVC {
                containerVC.view.addSubview(weakSelf!.volumeSlider)
            } else {
                weakSelf!.addSubview(volumeSlider)
            }
        }
        
        weakSelf!.volumeSlider.sideButtonModifyUpdateTTVolume(CGFloat(movedValue), isScreenChangeVolume)
        weakSelf!.avPlayerView?.volume = movedValue         //修改音量
        //取消隐藏秒延迟动画
        NSObject.cancelPreviousPerformRequests(withTarget: weakSelf!, selector: #selector(weakSelf!.removeVolumeView), object: nil)
        //延迟调用方法
        weakSelf!.perform(#selector(weakSelf!.removeVolumeView), with: nil, afterDelay: 2)
    }
    
}

// MARK: 屏幕手势
extension TTAVPlayer {
    
    // MARK: 删除音量控制View
    @objc fileprivate func removeVolumeView() -> Void {
        UIView.animate(withDuration: 1.2, animations: {
            self.volumeSlider.alpha = 0.0
        }) { (Bool) in
            self.volumeSlider.removeFromSuperview()
        }
    }
    
    // MARK: 删除亮度控制View
    @objc fileprivate func removeBrightnessView() -> Void {
        UIView.animate(withDuration: 1.2, animations: {
            self.brightnessSlider.alpha = 0.0
        }) { (Bool) in
            self.brightnessSlider.removeFromSuperview()
        }
    }
    
    // MARK: 调整音量和亮度
    fileprivate func volumeAndBrightnessVeloctyMoved(_ movedValue: CGFloat, _ isVolume: Bool) {
        if isVolume {
            volumeSlider.slidingModifyUpdateTTVolume(movedValue/10000)
        } else {
            brightnessSlider.updateTTBrightness(movedValue/10000)
        }
    }
    
    // MARK: 水平移动的距离视频跟随 滑动播放
    ///
    /// - Parameter slidingValue: 滑动的距离
    func horizontalSlidingValue(_ slidingValue: CGFloat) -> CGFloat {
        
        guard var sumValue = slidingTime else {
            return 0
        }
        // 这里可以调整拖动灵敏度， 数字（89）越大，灵敏度越低
        sumValue += (slidingValue / 89)
        //视频总时长
        let totalDurationTime = avPlayerView?.durationTime()
        
        guard let total = totalDurationTime else {
            return 0.0
        }
        
        if sumValue > total {
            sumValue = total
        }
        if sumValue < 0 {
            sumValue = 0
        }
        
        let dragValue = sumValue / total
        slidingTime = sumValue
        return dragValue
    }
    
    // MARK: 点击重播按钮
    @objc func clickReplay() -> Void {
        avPlayerView?.playSpecifyLocation(sliderTime: 0.0)
        ttAVPlayerStatus = TTAVPlayerStatus.Playing        //点击重播按钮
        replayBtn.isHidden = true
        tt_TopAndBottomBarShow(0.2, true)
    }
    
    // MARK: 按住屏幕上下滑动修改音量和亮度手势
    @objc func panGestureRecognizers(_ sender: UIPanGestureRecognizer) {
        //滑动的位置
        let locationPoint = sender.location(in: self)
        /// 根据上次和本次移动的位置，算出一个速率的point
        let veloctyPoint = sender.velocity(in: self)
        
        switch sender.state {
        case .began:    //开始滑动
            // 如果开始拖动屏幕则取消5秒自动消失控制栏
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.tt_TopAndBottomBarHidden), object: nil)
            // 使用绝对值来判断移动的方向
            let x = abs(veloctyPoint.x)
            let y = abs(veloctyPoint.y)
            
            if x > y {  //水平滑动
                //添加滑动进度View
                if !self.subviews.contains(slidePlayProgress) {
                    addSubview(slidePlayProgress)
                }
                
                ttPanDirection = TTPanDirection.TTPanDirectionHorizontal     //水平滑动状态
                self.ttAVPlayerStatus = TTAVPlayerStatus.Pause                    //水平滑动暂停播放
                playOrPauseBtn.isHidden = true                                    //隐藏暂停按钮
                //当前已经播放的时间
                slidingTime = avPlayerView?.currentTime()
                if isOrientation {  //是全屏状态
                    //取消隐藏动画后在重新添加5秒延迟动画
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.tt_TopAndBottomBarHidden(_:)), object: nil)
                    tt_TopAndBottomBarShow(0.2, false)
                } else {
                    tt_TopAndBottomBarHidden(0.2)       //滑动是隐藏顶部和底部Bar
                }
                TTLog("当前视频已经播放的时间\(slidingTime!)")
            } else if x < y {   //垂直滑动
                ttPanDirection = TTPanDirection.TTPanDirectionVertical     //垂直滑动状态
                if locationPoint.x > self.bounds.size.width / 2 && locationPoint.y < self.bounds.height - 50 { //右边垂直滑动
                    //                    TTLog("右边音量滑动")
                    if !self.subviews.contains(volumeSlider) {
                        // 调用系统的布局屁用没有  自定义的可以修改  可以和下面的亮度那样封装下
                        volumeSlider.alpha = 1
                        if isOrientation {
                            self.addSubview(volumeSlider)
                        } else {
                            if let containerVC = ttContainerVC {
                                containerVC.view.addSubview(volumeSlider)
                            } else {
                                self.addSubview(volumeSlider)
                            }
                        }
                    }
                } else if locationPoint.x < self.bounds.size.width / 2 && locationPoint.y < self.bounds.height - 50 { //左边亮度垂直滑动
                    //                    TTLog("左边亮度滑动")
                    if !self.subviews.contains(self.brightnessSlider) {
                        // 调用系统的布局屁用没有  自定义的可以修改  可以和下面的亮度那样封装下
                        brightnessSlider.alpha = 1
                        if isOrientation {
                            self.addSubview(brightnessSlider)
                        } else {
                            if let containerVC = ttContainerVC {
                                containerVC.view.addSubview(brightnessSlider)
                            } else {
                                self.addSubview(brightnessSlider)
                            }
                        }
                    }
                }
            }
            break
        case .changed:  //滑动中
            switch ttPanDirection! {
            case .TTPanDirectionHorizontal:
                replayBtn.isHidden = true            //滑动状态隐藏重播
                let draggedValue = self.horizontalSlidingValue(veloctyPoint.x)
                avPlayerView?.playSpecifyLocation(sliderTime: draggedValue)
                break
            case .TTPanDirectionVertical:
                if locationPoint.x > self.bounds.size.width / 2 && locationPoint.y < self.bounds.height - 50 { //右边音量垂直滑动
                    //取消隐藏秒延迟动画
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.removeVolumeView), object: nil)
                    brightnessSlider.removeFromSuperview()
                    isScreenChangeVolume = true             //滑动屏幕修改音量
                    volumeAndBrightnessVeloctyMoved(veloctyPoint.y, true)
                } else if locationPoint.x < self.bounds.size.width / 2 && locationPoint.y < self.bounds.height - 50 { //左边亮度垂直滑动
                    //取消隐藏秒延迟动画
                    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.removeBrightnessView), object: nil)
                    volumeSlider.removeFromSuperview()
                    volumeAndBrightnessVeloctyMoved(veloctyPoint.y, false)
                }
                break
            }
            break
        case .ended:    //滑动结束
            switch self.ttPanDirection! {
            case .TTPanDirectionHorizontal:
                ttAVPlayerStatus = TTAVPlayerStatus.Playing        //水平滑动完成 播放视频
                slidingTime = 0     //置空记录的播放时间
                //删除滑动进度View
                if self.subviews.contains(slidePlayProgress) {
                    slidePlayProgress.removeFromSuperview()
                }
                if isOrientation {  //是全屏状态
                    self.perform(#selector(self.tt_TopAndBottomBarHidden(_:)), with: nil, afterDelay: 5)
                }
                break
            case .TTPanDirectionVertical:
                if locationPoint.x < self.bounds.size.width/2 {    // 触摸点在视图左边 隐藏屏幕亮度
                    //延迟调用方法 //时间太短 延迟不了啊 晕倒 哈哈哈所以要使用这个方法 延迟的时间应该在设置在2秒以上
                    self.perform(#selector(self.removeBrightnessView), with: nil, afterDelay: 2)
                } else {
                    isScreenChangeVolume = false
                    //延迟调用方法
                    self.perform(#selector(self.removeVolumeView), with: nil, afterDelay: 2)
                }
                break
            }
            break
        case .possible:
            break
        case .failed:
            break
        case .cancelled:
            break
        default:
            break
        }
        
    }
    
    // MARK: 屏幕双击手势 播放或者暂停
    @objc func doubleTapGestureRecognizers(_ sender: UITapGestureRecognizer) {
        //如果是播放完成状态 双击屏幕不显示暂停按钮
        if ttAVPlayerStatus == TTAVPlayerStatus.EndTime {
            return
        }
        // 双击时直接响应播放暂停按钮点击
        if !isPausePlay {
            playOrPauseBtn.isHidden = false
            isPausePlay = true
            //取消隐藏动画后在重新添加5秒延迟动画
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.tt_TopAndBottomBarHidden(_:)), object: nil)
            tt_TopAndBottomBarHidden(0.2)                         //隐藏底部Bar控制View
            ttAVPlayerStatus = TTAVPlayerStatus.Pause        //播放完成暂停播放
        } else {
            playOrPauseBtn.isHidden = true
            isPausePlay = false
            //取消隐藏动画后在重新添加5秒延迟动画
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.tt_TopAndBottomBarHidden), object: nil)
            tt_TopAndBottomBarShow(0.2, true)                     //显示底部Bar控制View
            ttAVPlayerStatus = TTAVPlayerStatus.Playing       //播放完成暂停播放
        }
    }
    
    // MARK: 屏幕单击手势 隐藏或者显示顶部和底部控制Bar
    @objc func singleTapGestureRecognizers(_ sender: UITapGestureRecognizer) {
        
        if !topAndBottomBarHidden {
            tt_TopAndBottomBarHidden(0.2)        //隐藏顶部和底部Bar控制器
        } else {
            tt_TopAndBottomBarShow(0.2, true)           //显示顶部和底部Bar控制器
        }
    }
    
}

// MARK: - 顶部控制Bar 和 底部控制Bar 显示或消失动画
extension TTAVPlayer {
    
    // MARK: 顶部和底部Bar展现动画
    /// 顶部和底部Bar展现动画
    @objc func tt_TopAndBottomBarShow(_ duration: TimeInterval, _ isHiddenBar: Bool) -> Void {
        // 动画消失 顶部和底部控制Bar
        UIView.animate(withDuration: duration, animations: {
            self.topAndBottomBarHidden = false
            if self.isOrientation { //如果是全屏展现Bar
                //显示控制器Bar
                self.bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale*65, width: self.frame.width, height: kScale*65)
                self.topBarView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: kScale*65)
            } else {
                self.bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale*50, width: self.frame.width, height: kScale*50)
            }
            self.bottomBarView.alpha = 1.0
            self.topBarView.alpha = 1.0
            
        }) { (Bool) in
            if isHiddenBar {
                //显示bar后，5秒后重新添加5秒延迟消失bar动画
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.tt_TopAndBottomBarHidden), object: nil)
                //延迟五秒调用方法
                self.perform(#selector(self.tt_TopAndBottomBarHidden(_:)), with: nil, afterDelay: 5)
            }
            
        }
    }
    
    // MARK: 顶部和底部Bar消失动画
    /// 顶部和底部Bar消失动画
    @objc func tt_TopAndBottomBarHidden(_ duration: TimeInterval) -> Void {
        let tt_Duration = duration > 0 ? duration : 0.5
        // 动画消失 顶部和底部控制Bar
        UIView.animate(withDuration: tt_Duration) {
            self.topAndBottomBarHidden = true
            if self.isOrientation { //如果是全屏就隐藏顶部和底部Bar
                self.topBarView.frame = CGRect(x: 0, y: -kScale*65, width: self.bounds.width, height: kScale*65)
                self.bottomBarView.frame = CGRect(x: 0, y: self.frame.height + kScale*65, width: self.frame.width, height: kScale*65)
            } else {
                self.bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale*50, width: self.frame.width, height: kScale*50)
            }
            self.topBarView.alpha = 0.0
            self.bottomBarView.alpha = 0.0
        }
    }
    
}

// MARK: - 顶部控制Bar TTTopBarDelegate  代理方法
extension TTAVPlayer {
    // MARK: 顶部更多按钮
    func tt_ClickTopBarMoreButton() {
        //更多按钮回调
        if let ttDelegate = delegate {
            ttDelegate.tt_avPlayerTopBarMoreButton?()
        }
    }
    // MARK: 顶部返回按钮
    func tt_ClickTopBarBackButton() {
        
        if isOrientation {
            tt_UIInterfaceOrientation(UIInterfaceOrientation.portrait)          //默认屏幕方向
            isOrientation = false
            setupResetSubviewLayout()           //重置子视图布局
            avPlayerView?.ttOrientationPortraitAnimation()       //改变 playerLayer 大小
            if let vcView = ttContainerVC {
                vcView.view.addSubview(self)
            } else {
                ttContainerView?.addSubview(self)
            }
            ttPlayerOrientationPortraitAnimation()
            topBarView.isFullScreen = TTPlayTopBarType.Normal         //竖屏状态
            bottomBarView.isFullScreen = TTPlayBottomBarType.Normal   //竖屏状态
            topBarView.isHidden = isHiddenTopBar
            topBarView.backButton?.isHidden = isHiddenTopBarBackButton
            topBarView.videoNameLable.isHidden = isHiddenTopBarVideoName
            topBarView.moreButton?.isHidden = isHiddenTopBarMoreButton
        } else {
            var index = 0
            if let containerVC = ttContainerVC {
                index = containerVC.navigationController?.viewControllers.lastIndex(of: containerVC) ?? 0
            }
            if index > 1 {
                ttContainerVC?.navigationController?.popViewController(animated: true)
            }
        }
        //返回按钮回调
        if let ttDelegate = delegate {
            ttDelegate.tt_avPlayerTopBarBackButton?()
        }
    }
}

// MARK: - 底部控制Bar TTBottomBarDelegate  代理方法
extension TTAVPlayer {
    
    // MARK: 强制横屏 通过KVC直接设置屏幕旋转方向
    fileprivate func tt_UIInterfaceOrientation(_ orientation: UIInterfaceOrientation) {
        
        if orientation == UIInterfaceOrientation.landscapeRight || orientation == UIInterfaceOrientation.landscapeLeft {
            tt_OrientationSupport = TTOrientationSupport.orientationRight //左右
            UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.landscapeRight.rawValue), forKey: "orientation")
        } else if orientation == UIInterfaceOrientation.portrait {
            tt_OrientationSupport = TTOrientationSupport.orientationPortrait  //上下左右
            UIDevice.current.setValue(NSNumber(integerLiteral: UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    // MARK: 旋转全屏动画
    fileprivate func ttPlayerOrientationLeftAndRightAnimation() -> Void {
        let transformAnima = CABasicAnimation(keyPath: "transform.rotation")
        transformAnima.fromValue = -(Double.pi/2)
        transformAnima.toValue = 0
        transformAnima.duration = 0.2       //动画时间
        transformAnima.isRemovedOnCompletion = true
        transformAnima.fillMode = CAMediaTimingFillMode.forwards
        self.layer.add(transformAnima, forKey: "transform.rotation")
    }
    
    // MARK: 旋转竖屏动画
    fileprivate func ttPlayerOrientationPortraitAnimation() -> Void {
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
            setupResetSubviewLayout()       //重置子视图布局
            bottomBarView.fullScreenPlayTitle = "倍速"
            avPlayerView?.ttOrientationLeftAndRightAnimation()       //改变 playerLayer 大小
            UIApplication.shared.keyWindow?.addSubview(self)         //播放器加载到window 上
            ttPlayerOrientationLeftAndRightAnimation()
            topBarView.isFullScreen = TTPlayTopBarType.Full             //全屏状态
            bottomBarView.isFullScreen = TTPlayBottomBarType.Full       //全屏状态
            topBarView.isHidden = false
            topBarView.backButton?.isHidden = false
            topBarView.videoNameLable.isHidden = false
            topBarView.moreButton?.isHidden = false
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.tt_TopAndBottomBarHidden(_:)), object: nil)
            self.perform(#selector(self.tt_TopAndBottomBarHidden(_:)), with: nil, afterDelay: 5)
            
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
        //全屏回调
        if let ttDelegate = delegate {
            ttDelegate.tt_avPlayerBottomBarFullScreenPlayButton?()
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
        tt_TopAndBottomBarShow(0.1, true)
        replayBtn.isHidden = true        //滑动状态隐藏重播
        playOrPauseBtn.isHidden = true   //滑动状态隐藏暂停按钮
    }
    
    // MARK: 点击播放 和 暂停播放
    ///
    /// - Parameter isPlay: 是否播放 默认是播放状态
    func tt_ClickPlayButton(isPlay: Bool) {
        if ttAVPlayerStatus == TTAVPlayerStatus.Playing {
            self.ttAVPlayerStatus = TTAVPlayerStatus.Pause //暂停
        } else if ttAVPlayerStatus == TTAVPlayerStatus.Pause {
            self.ttAVPlayerStatus = TTAVPlayerStatus.Playing //播放
            playOrPauseBtn.isHidden = true
        } else if ttAVPlayerStatus == TTAVPlayerStatus.EndTime { 
            clickReplay()  //播放完成在点击播放按钮重播
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
        replayBtn.isHidden = false
        tt_TopAndBottomBarShow(0.2, false)
    }
    
    // MARK: 缓冲完成播放
    func tt_PlayBufferToComplete() {
        bottomBarView.isSelectedPlay = true
        panGesture.isEnabled = true             //打开屏幕滑动手势
        //延迟五秒隐藏底部Bar
        self.perform(#selector(self.tt_TopAndBottomBarHidden(_:)), with: nil, afterDelay: 5)
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
        //视频中间的进度显示View
        slidePlayProgress.maximumValue = maximumValue
        slidePlayProgress.value = sliderValue
        slidePlayProgress.playTimeValue = playTimeValue
    }
}
