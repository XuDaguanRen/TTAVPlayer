//
//  TTBottomBarView.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 枚举
/// 播放是否全屏
///
/// - normal: 正常状态
/// - full: 全屏状态
enum TTPlayBottomBarType {
    case Normal
    case Full
}

// MARK: - 代理
@objc protocol TTBottomBarDelegate: NSObjectProtocol {
    
    // MARK: 全屏播放按钮
    func tt_ClickFullScreenPlayButton() -> Void
    
    // MARK: 点击滑动控件结束监听
    /// 点击滑动控件结束监听
    ///
    /// - Parameter selider: selider: 控件
    func tt_SliderDidEnd(slider: UISlider) -> Void
    
    // MARK: 滑动开始监听
    /// 滑动开始监听
    ///
    /// - Parameter selider: 控件
    func tt_SliderChanged(slider: UISlider) -> Void
    
    // MARK: 播放按钮
    func tt_ClickPlayButton(isPlay: Bool) -> Void
}

class TTBottomBarView: UIView {
    // MARK: - 属性
    /// 代理
    weak open var delegate: TTBottomBarDelegate?
    /// slider高度
    private var ttEliderHeight: CGFloat = 0.0
    /// 播放按钮
    var playBtn = UIButton()
    /// 播放按钮图片
    var playButtonImageView: UIImageView?
    /// 按钮状态
    var isSelectedPlay: Bool = false {
        didSet {
            if isSelectedPlay {
                playButtonImageView?.image = UIImage.init(named: "player_ctrl_icon_pause")
            } else {
                playButtonImageView?.image = UIImage.init(named: "player_ctrl_icon_play")
            }
            playBtn.isSelected = isSelectedPlay
        }
    }
    /// 播放时间
    private var playTimeL = UILabel()
    /// 播放了多少时间
    var playTimeValue: String = "00:00" {
        didSet {
            playTimeL.text = playTimeValue
        }
    }
    /// 中间分割线
    private var lineView = UIView()
    /// 视频一共多长时间
    private var endTimeL = UILabel()
    /// 播放总时长
    var endTimeValue: String = "00:00" {
        didSet {
            endTimeL.text = endTimeValue
        }
    }
    /// 全屏播放按钮
    private var fullScreenPlayBtn = UIButton()
    /// 全屏播放按钮图片
    var fullPlayImageView: UIImageView?
    /// 按钮标题
    var fullScreenPlayTitle: String = "" {
        didSet {
           fullScreenPlayBtn.setTitle(self.fullScreenPlayTitle, for: .normal)
        }
    }
    /// 进度调控件
    var ttSlider = TTSlider.init()
    /// 最小值
    var minimumValue: Float = 0.0 {
        didSet {
            self.ttSlider.maximumValue = self.minimumValue
        }
    }
    /// 最大值
    var maximumValue: Float = 0.0 {
        didSet {
            self.ttSlider.maximumValue = self.maximumValue
        }
    }
    /// 当前值
    var value: Float = 0.0 {
        didSet {
            self.ttSlider.value = self.value
        }
    }
    /// 进度条左边颜色
    var sliderMinimumTrackTintColor: UIColor = UIColor.init() {
        didSet {
            self.ttSlider.minimumTrackTintColor = self.sliderMinimumTrackTintColor;
        }
    }
    /// 进度条右边槽的颜色
    var sliderMaximumTrackTintColor: UIColor = UIColor.init() {
        didSet {
            self.ttSlider.maximumTrackTintColor = self.sliderMaximumTrackTintColor;
        }
    }
    /// 进度条颜色
    var thumbImage: UIImage = UIImage.init(named: "fullplayer_progress_point")! {
        didSet {
            self.ttSlider.setThumbImage(self.thumbImage, for: .normal)
        }
    }
    /// 是否是全屏状态
    var isFullScreen: TTPlayBottomBarType? {
        didSet {
            if self.isFullScreen == TTPlayBottomBarType.Full {
                ttLayoutIfNeededFullSliderView()
            } else {
                ttLayoutIfNeededNormalSliderView()
            }
            self.layoutIfNeeded()
        }
    }
    /// 播放栏背景蒙版
    fileprivate var barMaskImageView = UIImageView.init(image: UIImage.init(named: "miniplayer_mask"))
    
    // MARK: - 初始化方法
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - sliderHeight: sliderView高度
    init(frame: CGRect, sliderHeight: CGFloat) {
        super.init(frame: frame)
        setupBottomBarUI(frame: frame, sliderHeight: sliderHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 布局页面
    func setupBottomBarUI(frame: CGRect, sliderHeight: CGFloat) -> Void {
       
        barMaskImageView.frame = self.bounds
        self.addSubview(barMaskImageView)
        
        ttEliderHeight = sliderHeight
        
        playBtn.frame = CGRect(x: 0, y: 0, width: frame.height + kScale * 10, height: frame.height)
        playBtn.addTarget(self, action: #selector(clickPlayButton), for: .touchUpInside)
        
        self.addSubview(playBtn)
        
        playButtonImageView = UIImageView.init(frame: CGRect(x: (playBtn.frame.width - kScale * 28) / 2, y: (playBtn.frame.height - kScale * 28) / 2, width:  kScale * 28, height: kScale * 28))
        playBtn.addSubview(playButtonImageView!)
        playButtonImageView?.image = UIImage.init(named: "player_ctrl_icon_pause")
        
        //开始时间
        playTimeL.frame = CGRect(x: playBtn.right + kScale * 1, y: (frame.height - kScale * 16) / 2, width: kScale * 48, height: kScale * 16)
        playTimeL.text = self.playTimeValue
        playTimeL.font = UIFont.systemFont(ofSize: kScale * 14)
        playTimeL.textColor = UIColor.white
        playTimeL.textAlignment = .center
        self.addSubview(playTimeL)
        
        //中间分割线
        lineView = UIView.init(frame: CGRect(x: playTimeL.right, y: (frame.height - kScale * 12) / 2, width: kScale * 1, height: kScale * 12))
        lineView.backgroundColor = UIColor.white
        var transform = CGAffineTransform();
        transform = CGAffineTransform.init(rotationAngle: (CGFloat(Double.pi * 0.05)))
        lineView.transform = transform;
        self.addSubview(lineView)
        
        //结束时间
        endTimeL.frame = CGRect(x: lineView.right, y: (frame.height - kScale * 16)/2, width: kScale * 48, height: kScale * 16)
        endTimeL.text = self.playTimeValue
        endTimeL.font = UIFont.systemFont(ofSize: kScale * 14)
        endTimeL.textAlignment = .center
        endTimeL.textColor = UIColor.white
        self.addSubview(endTimeL)
        
        //全屏按钮 X
        let fullScreenPlayX =  (frame.size.width - frame.height)
        
        //Y
        let sliderY =  (frame.size.height - sliderHeight) / 2
        //宽度
        let sliderWidth =  (frame.size.width - playBtn.width - kScale * 10 - playTimeL.width - endTimeL.width - frame.height - kScale * 10)
        ttSlider.frame = CGRect(x: endTimeL.right + kScale * 5, y: sliderY, width: sliderWidth, height: sliderHeight);
        ttSlider.setThumbImage(self.thumbImage, for: .normal)
        ttSlider.setMinimumTrackImage(UIImage.init(named: "progress_bg03"), for: .normal)
        ttSlider.ttHeight = 1 * kScale
        ttSlider.minimumValue = self.minimumValue
        ttSlider.maximumValue = self.maximumValue
        
        //        ttSlider.isContinuous = false //滑块滑动停止后才触发ValueChanged事件
        //滑动中
        ttSlider.addTarget(self, action: #selector(ttSliderChanged(slider:)), for: .valueChanged)
        
        weak var weakSelf = self
        //滑动结束
        ttSlider.sliderTouchesEndedBlock = { (slider) in
            weakSelf?.delegate?.tt_SliderDidEnd(slider: slider) //代理
        }
        
        self.addSubview(ttSlider)
        
        fullScreenPlayBtn.frame = CGRect(x: fullScreenPlayX - kScale * 10, y: 0, width: frame.height + kScale * 10, height: frame.height)
        //        fullScreenPlay.setImage(UIImage.init(named: "tticon_zoom02"), for: .normal)
        fullScreenPlayBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        fullScreenPlayBtn.addTarget(self, action: #selector(clickFullScreenPlayButton), for: .touchUpInside)
        
        self.addSubview(fullScreenPlayBtn)
        //按钮图片
        fullPlayImageView = UIImageView.init(frame: CGRect(x: (playBtn.frame.width - kScale * 28) / 2, y: (playBtn.frame.height - kScale * 28) / 2, width:  kScale * 28, height: kScale * 28))
        fullScreenPlayBtn.addSubview(fullPlayImageView!)
        fullPlayImageView?.image = UIImage.init(named: "player_icon_fullscreen")

    }
    
}

// MARK: - 方法实现
extension TTBottomBarView {
    
    // MARK: 全屏播放按钮
    @objc private func clickFullScreenPlayButton() -> Void {
        if let delegate = delegate {
            delegate.tt_ClickFullScreenPlayButton() 
        }
    }
    
    // MARK: 滑动开始监听
    @objc private func ttSliderChanged(slider: UISlider) -> Void {
        if let delegate = delegate {
            delegate.tt_SliderChanged(slider: slider) //代理
        }
    }
    
    // MARK: 修改布局 正常
    func ttLayoutIfNeededNormalSliderView() -> Void {
        //开始时间
        UIView.animate(withDuration: 0.0, animations: {
            //隐藏控件
            self.playTimeL.isHidden = true
            self.endTimeL.isHidden = true
            self.lineView.isHidden = true
            self.fullScreenPlayBtn.isHidden = true
            self.ttSlider.isHidden = true
            self.fullScreenPlayTitle = ""       //竖屏不显示全屏按钮标题
            
        }) { (Bool) in
            //播放按钮
            self.playBtn.frame = CGRect(x: 0, y: 0, width: self.frame.height + kScale * 10, height: self.frame.height)
            //按钮图片
            self.playButtonImageView?.frame = CGRect(x: (self.playBtn.frame.width - kScale * 28) / 2, y: (self.playBtn.frame.height - kScale * 28) / 2, width: kScale * 28, height: kScale * 28)
            //开始时间
            self.playTimeL.frame = CGRect(x: self.playBtn.right + kScale * 1, y: (self.frame.height - kScale * 16) / 2, width: kScale * 48, height: kScale * 16)
            //结束时间
            self.endTimeL.frame = CGRect(x: self.lineView.right, y: (self.frame.height - kScale * 16)/2, width: kScale * 48, height: kScale * 16)
            //Y
            let sliderY =  (self.frame.size.height - self.ttEliderHeight) / 2
            //宽度
            let sliderWidth =  (self.frame.size.width - self.playBtn.width - self.playTimeL.width - self.endTimeL.width - self.frame.height - kScale * 10)
            
            self.ttSlider.frame = CGRect(x: self.endTimeL.right + kScale * 5, y: sliderY, width: sliderWidth, height: self.ttEliderHeight);
            //全屏按钮 X
            let fullScreenPlayX =  (self.frame.size.width - self.frame.height)
            
            self.fullScreenPlayBtn.frame = CGRect(x: fullScreenPlayX, y: 0, width: self.frame.height, height: self.frame.height)

            self.barMaskImageView.frame = self.bounds
            //隐藏控件
            self.playTimeL.isHidden = false
            self.endTimeL.isHidden = false
            self.lineView.isHidden = false
            self.fullScreenPlayBtn.isHidden = false
            self.ttSlider.isHidden = false
            self.fullPlayImageView?.isHidden = false
        }
    }
    
    // MARK: 修改布局 全屏
    func ttLayoutIfNeededFullSliderView() -> Void {
        //开始时间
        UIView.animate(withDuration: 0.0, animations: {
            //隐藏控件
            self.playTimeL.isHidden = true
            self.endTimeL.isHidden = true
            self.lineView.isHidden = true
            self.fullScreenPlayBtn.isHidden = true
            self.ttSlider.isHidden = true
            self.fullPlayImageView?.isHidden = true
        }) { (Bool) in
            
            self.playTimeL.frame = CGRect(x: self.playBtn.right + kScale * 5, y: (self.frame.height - kScale * 16) / 2 + kScale * 5, width: kScale * 58, height: kScale * 16)
            //Y
            let sliderY =  (self.frame.size.height - self.ttEliderHeight) / 2
            //宽度
            let sliderWidth =  (self.frame.size.width - self.playBtn.width - self.playTimeL.width - self.endTimeL.width - self.fullScreenPlayBtn.width - kScale * 35)
            
            self.ttSlider.frame = CGRect(x: self.playTimeL.right + kScale * 5, y: sliderY + kScale * 5, width: sliderWidth, height: self.ttEliderHeight);
            //结束时间
            self.endTimeL.frame = CGRect(x: self.ttSlider.right + kScale * 10, y: (self.frame.height - kScale * 16)/2 + kScale * 5, width: kScale * 58, height: kScale * 16)
            //全屏按钮 X
            let fullScreenPlayX =  (self.frame.size.width - self.frame.height)
            
            self.fullScreenPlayBtn.frame = CGRect(x: fullScreenPlayX - kScale * 10, y: kScale * 10, width: self.frame.height + kScale * 10, height: self.frame.height - kScale * 10)
            
            self.playBtn.frame = CGRect(x: 0, y: kScale * 10, width: self.frame.height + kScale * 10, height: self.frame.height - kScale * 10)
            
            self.playButtonImageView?.frame = CGRect(x: (self.playBtn.frame.width - kScale * 28) / 2, y: (self.playBtn.frame.height - kScale * 28) / 2, width: kScale * 28, height: kScale * 28)
            
            self.barMaskImageView.frame = self.bounds
            
            //是否隐藏控件
            self.playTimeL.isHidden = false
            self.endTimeL.isHidden = false
            self.fullScreenPlayBtn.isHidden = false
            self.ttSlider.isHidden = false
        }
    }
    
    // MARK: 播放按钮
    @objc private func clickPlayButton() -> Void {
        if let delegate = delegate {
            delegate.tt_ClickPlayButton(isPlay: playBtn.isSelected)  //代理
        }
    }
}
