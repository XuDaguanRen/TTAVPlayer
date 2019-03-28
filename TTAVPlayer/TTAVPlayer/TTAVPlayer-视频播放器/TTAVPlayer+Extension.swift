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
        
    }
    // MARK: 滑动进度条
    ///
    /// - Parameter selider: 进度数据
    func tt_SliderChanged(slider: UISlider) {
        
    }
    // MARK: 点击播放 和 暂停播放
    ///
    /// - Parameter isPlay: 是否播放 默认是播放状态
    func tt_ClickPlayButton(isPlay: Bool) {
        
    }
}

// MARK: - TTAVPlayerViewDelegate 代理方法
extension TTAVPlayer {
    
    // MARK: 获取到播放状态
    func tt_PlayerStatus(playerStatus: TTPlayerStatus) {
        
    }
    
    // MARK: 播放完成
    func tt_PlayToEndTime() {
 
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
