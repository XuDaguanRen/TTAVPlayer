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
    /// 播放文件路径
    var urlString: String = "" {
        didSet {
            if !self.urlString.isEmpty {
                exchangeWithURL(videoURLStr: self.urlString) //视频切换
            }
        }
    }
    /// 音量设置
    var volume: Float = AVAudioSession.sharedInstance().outputVolume {
        didSet {
           player?.volume = volume
        }
    }
    
    /// 播放速度
    var rate: CGFloat = 1.0 {
        didSet {
            
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
        //设置系统音量
        self.player?.volume = volume
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
    
    // MARK: 切换视频调用方法
    fileprivate func exchangeWithURL(videoURLStr : String)  {
        
        self.playerItem = self.getPlayItemWithURLString(url: videoURLStr)
        self.player?.replaceCurrentItem(with: self.playerItem)
        
    }
    
    // MARK: 暂停播放
    func clickPause(){
        player?.pause()
    }
    
    // MARK: 开始播放
    func clickPlay(){
        player?.play()
    }
    
    // MARK: 转时间格式
    /// - Parameters:
    ///   - position: 当前时间
    ///   - duration: 总时间
    fileprivate func changeTimeFormat(position: Int, duration:Int) -> String {
        
        guard  duration != 0 else{
            return "00:00"
        }
        let durationHours = (duration / 3600) % 60            //小时
        let durationMinutes = (duration / 60) % 60            //分钟
        let durationSeconds = duration % 60                   //秒
        if (durationHours == 0)  {
            return String(format: "%02d:%02d",durationMinutes,durationSeconds)
        }
        return String(format: "%d:%02d:%02d",durationHours,durationMinutes,durationSeconds)
    }
    
    // MARK: KVO观察
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            switch self.playerItem?.status {
            case .readyToPlay?: //指示播放器项已准备好要播放
                
                break
            case .failed?: //指示由于错误不能再播放播放器
                
                break
            case.unknown?: // 指示尚未知道播放器状态，因为它尚未尝试加载新媒体资源
                
                break
            default:
                break;
            }
        } else if keyPath == "loadedTimeRanges"{  //缓冲的所有时间
            let loadTimeArray = self.playerItem?.loadedTimeRanges
            //如果缓冲时间数组有 则走下面
            if !(loadTimeArray?.isEmpty)! {
                //获取最新缓存的区间
                let newTimeRange : CMTimeRange = loadTimeArray?.first as! CMTimeRange
                let startSeconds = CMTimeGetSeconds(newTimeRange.start);
                let durationSeconds = CMTimeGetSeconds(newTimeRange.duration);
                let _ = startSeconds + durationSeconds;   //缓冲总长度
                TTLog("当前缓冲总长度")
            }
            
        } else if keyPath == "playbackBufferEmpty" {  //正在缓存视频请稍等
            
        } else if keyPath == "playbackLikelyToKeepUp" { //缓存好了可以播放了
            
        }
    }
    
    // MARK: 监听Player状态
    fileprivate func listenPlayer() -> Void {
        guard let player = self.player else {return}
        //        weak var weakSelf = self
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: Int64(1.0), timescale: Int32(1.0)), queue: nil, using: { [weak self] (time) in
            
            /*
             “添加周期时间观察者” ，参数1 interal 为CMTime 类型的，参数2 queue为串行队列，如果传入NULL就是默认主线程，参数3 为CMTime 的block类型。
             简而言之就是，每隔一段时间后执行 block。
             比如：我们把interval设置成CMTimeMake(1, 10)，在block里面刷新label，就是一秒钟刷新10次。
             */
            
            //当前正在播放的时间
            let loadTime = CMTimeGetSeconds(time)
            //视频总时间
            let totalTime = CMTimeGetSeconds((player.currentItem?.asset.duration)!)
            //视频最大进度
            let maximumValue = Float(Int(totalTime) % 3600)
            // 播放了多少
            let playTimeValue = self?.changeTimeFormat(position: Int(loadTime), duration: Int(loadTime))
            //视频总时长
            let endTimeValue = self?.changeTimeFormat(position: Int(loadTime), duration: Int(totalTime))
            
        })
    }
    
    // MARK: - 初始化playerItem
    fileprivate func getPlayItemWithURLString(url: String) -> AVPlayerItem {
        
        ///初始化播放 item
        var urlString = NSURL.init(string: url)
        if urlString == nil {
            if url.contains("var") ||  url.contains("Users") {
                urlString = NSURL.init(fileURLWithPath: url)
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
