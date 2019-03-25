//
//  TTAVPlayerView.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/25.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class TTAVPlayerView: UIView {

    /// 播放器
    fileprivate var player: AVPlayer?
    /// 创建视频资源
    fileprivate var playerItem: AVPlayerItem?
    /// 创建显示视频的图层
    fileprivate var playerLayer: AVPlayerLayer?
    /// 视频集合
    fileprivate var avAsset: AVAsset?
    /// 播放速度
    var rate: CGFloat = 1.0 {
        didSet {
        
        }
    }
    /// 播放文件路径
    var urlString: String = "" {
        didSet {
            if !self.urlString.isEmpty {

            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        
        setupAVPlayerUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    /// 初始化设置
    func setupAVPlayerUI() -> Void {
        //创建视频资源
        self.playerItem = getPlayItemWithURLString(url: urlString)
        
        //创建AVplayer：负责视频播放
        self.player = AVPlayer.init(playerItem: self.playerItem)
        self.player?.volume = AVAudioSession.sharedInstance().outputVolume //设置系统音量
        //播放速度 播放前设置
        self.player?.rate = Float(self.rate)
        //创建显示视频的图层
        self.playerLayer = AVPlayerLayer.init(player: self.player)
        /*
         解释是
         1. resizeAspect 保持纵横比；适合层范围内
         2. resizeAspectFill 保持纵横比；填充层边界
         3. resize 拉伸填充层边界
         */
        self.playerLayer!.videoGravity = .resizeAspectFill
        self.playerLayer!.frame = self.bounds
        self.layer.addSublayer(self.playerLayer!)
        
    }
    
}

// MARK: - 方法实现
extension TTAVPlayerView {
    
    
    // MARK: 初始化playerItem
    fileprivate func getPlayItemWithURLString(url: String) -> AVPlayerItem {
        
        ///初始化播放 item
        var urlString = NSURL.init(string: url)
        if urlString == nil {
            if url.contains("var") ||  url.contains("Users") {
                urlString = NSURL.init(fileURLWithPath: url)
                //                TTLog("是本地路径 \(urlString!)")
            }
        }
        TTLog("视频路径 \(urlString!)")
        avAsset = AVAsset.init(url: urlString! as URL)
        let Item = AVPlayerItem.init(asset: self.avAsset!)
        
        if self.playerItem == Item {
            return self.playerItem!
        }
        //不等于空切换了视频 删除原有的
        if let tempPlayerItem = self.playerItem {
            tempPlayerItem.removeObserver(self, forKeyPath: "status", context: nil)
            tempPlayerItem.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
            tempPlayerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
            tempPlayerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: nil)
        }
        /// 观察属性
        /// 监听状态改变
        Item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        /// 监听缓存时间
        Item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        /// 监听缓存够不够
        Item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        /// 监听缓存足够播放的状态 playbackLikelyToKeepUp和playbackBufferEmpty是一对
        Item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        
        return Item
    }
}
