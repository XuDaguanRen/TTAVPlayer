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

// MARK: - 底部控制Bar TTBottomBarDelegate  代理方法
extension TTAVPlayer {
    
     // MARK: 全屏播放
    func tt_ClickFullScreenPlayButton() {
        
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
