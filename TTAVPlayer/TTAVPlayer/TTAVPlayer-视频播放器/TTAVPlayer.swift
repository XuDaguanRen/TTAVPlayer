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
// MARK: - 滑动手势的方向枚举
enum TTPanDirection: Int {
    case TTPanDirectionHorizontal     //水平
    case TTPanDirectionVertical       //上下
}

// MARK: - 代理
@objc protocol TTAVPlayerDelegate: NSObjectProtocol {
    
    /// 播放器加载状态
    @objc optional func tt_avPlayerStatus(status: TTAVPlayerStatus) -> Void
    
    /// 顶部选集按钮
    @objc optional func tt_avPlayerTopBarMoreButton() -> Void
    
    ///  顶部返回按钮
    @objc optional func tt_avPlayerTopBarBackButton() -> Void
    
    /// 底部部全屏按钮
    @objc optional func tt_avPlayerBottomBarFullScreenPlayButton() -> Void
    
}

class TTAVPlayer: UIView, TTAVPlayerViewDelegate, TTBottomBarDelegate, TTTopBarDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - 属性
    /// 代理
    weak var delegate: TTAVPlayerDelegate?
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
    /// 滑动方向枚举
    var ttPanDirection: TTPanDirection?     //滑动手势的方向
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
    var rate: Float = 1.0 {
        didSet {
            self.avPlayerView?.rate = rate
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
    /// 单击手势
    lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(singleTapGestureRecognizers(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    /// 双击手势
    lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(doubleTapGestureRecognizers(_:)))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    /// 滑动手势
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(panGestureRecognizers(_:)))
        gesture.delegate = self
        gesture.maximumNumberOfTouches = 1
        gesture.isEnabled = false          //先让手势不能触发 全屏的时候在触发手势
        return gesture
    }()
    /// 是否隐藏bar
    var topAndBottomBarHidden: Bool = false
    /// 暂停提示按钮
    lazy var playOrPauseBtn: UIButton = {
        let button = UIButton.init(frame: CGRect(x: (self.frame.width - kScale*125)/2, y: (self.frame.height - kScale*40)/2, width: kScale*125, height: kScale*40))
        button.setImage(UIImage.init(named: "player_ctrl_icon_pause"), for: .normal)
        button.setTitle("  已暂停", for: .normal)
        button.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        button.titleLabel?.font = UIFont.systemFont(ofSize: kScale*19)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.isHidden = true
        return button
    }()
    /// 暂停提示按钮
    lazy var replayBtn: UIButton = {
        let button = UIButton.init(frame: CGRect(x: (self.frame.width - kScale*80)/2, y: (self.frame.height - kScale*80)/2, width: kScale*80, height: kScale*80))
        button.setTitle("重播", for: .normal)
        button.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        button.titleLabel?.font = UIFont.systemFont(ofSize: kScale*20)
        button.layer.cornerRadius = button.frame.height/2
        button.layer.masksToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(clickReplay), for: .touchUpInside)
        return button
    }()
    /// 双击屏幕时修改播放状态
    var isPausePlay: Bool = false
    /// 滑动播放显示进度控件
    lazy var slidePlayProgress: TTSlidePlayProgress = {
        let slideProgress = TTSlidePlayProgress.init(frame: CGRect(x: (self.frame.width - kScale*160)/2, y: (self.frame.height - kScale*80)/2 - kScale*20, width: kScale*160, height: kScale*80))
        slideProgress.backgroundColor = UIColor.clear
        return slideProgress
    }()
    var slidingTime: CGFloat?               //记录当前已经播放的时间
    /// 音量显示
    lazy var volumeSlider: TTMPVolumeView = {
        let volumeView = TTMPVolumeView.init(frame: CGRect(x: 0, y: 0, width: kScale*180, height: kScale*180))
        volumeView.backgroundColor = UIColor.init(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.9)
        return volumeView
    }()
    /// 是否是屏幕滑动修改音量
    var isScreenChangeVolume: Bool = false
    /// 亮度显示
    var brightnessSlider: TTBrightnessView = {
        let brightView = TTBrightnessView.init(frame: CGRect(x: 0, y: 0, width: kScale*180, height: kScale*180))
        brightView.backgroundColor = UIColor.init(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.9)
        return brightView
    }()
    /// 在前后台切换时记录播放状态
    var beforeChangePlayerStatus: TTAVPlayerStatus?
    /// 是否在后台时继续播放
    var isPlayingInBackground: Bool?

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
    
    // MARK: 解决视图长按滑动手势和底部Sliderz拖拽进度手势冲突问题
    private func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isKind(of: TTSlider.self) {
            //            TTLog("是TTSlider")
            return false
        }
        return true
    }
    
    // MARK: 修改音量和亮度布局
    func layoutIfNeededVolumeAndbrightness() -> Void {
        self.volumeSlider.removeFromSuperview()
        self.brightnessSlider.removeFromSuperview()
        let ttCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        if ttContainerVC != nil {
            if isOrientation {
                volumeSlider.center = ttCenter
                brightnessSlider.center = ttCenter
            } else {
                volumeSlider.center = CGPoint(x: ttCenter.x, y: ttCenter.y + volumeSlider.bounds.height/2)
                brightnessSlider.center = CGPoint(x: ttCenter.x, y: ttCenter.y + brightnessSlider.bounds.height/2)
            }
        } else {
            volumeSlider.center = CGPoint(x: ttCenter.x, y: ttCenter.y + volumeSlider.bounds.height/2)
            brightnessSlider.center = CGPoint(x: ttCenter.x, y: ttCenter.y + brightnessSlider.bounds.height/2)
        }
    }
    
    // MARK: 隐藏系统自身音量控制
    func setupHideSystemVolume() -> Void {
        guard let containerVC = ttContainerVC else { return }
        //隐藏了系统的声音View 使用自定义的 如果系统的音量控制不加载到控制器中 这中隐藏方法不起作用
        let volumeView = TTMPVolume.init(frame: CGRect(x: -1000, y: -1000, width: 155, height: 155))
        containerVC.view.addSubview(volumeView)
    }
    
    // MARK: 重置子视图布局
    func setupResetSubviewLayout() -> Void {
        self.removeFromSuperview()
        if isOrientation { //横屏状态
            self.frame = (UIApplication.shared.keyWindow?.bounds)!
            avPlayerView?.frame = self.frame
            bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale*65, width: self.frame.width, height: kScale*65)
            topBarView.frame = CGRect(x: 0, y: 0, width:  self.frame.width, height: kScale*65)
            playOrPauseBtn.frame = CGRect(x: (self.frame.width - kScale*125)/2, y:  (self.frame.height - kScale*40)/2, width: kScale*125, height: kScale*40)
            replayBtn.frame = CGRect(x: (self.frame.width - kScale*80)/2, y: (self.frame.height - kScale*80)/2, width: kScale*80, height: kScale*80)
            
        } else { //竖屏状态
            self.frame = ttFrame!
            avPlayerView?.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            bottomBarView.frame = CGRect(x: 0, y: self.frame.height - kScale*50, width: self.frame.width, height: kScale*50)
            topBarView.frame = CGRect(x: 0, y: 0, width:  self.frame.width, height: kScale*50)
            playOrPauseBtn.frame = CGRect(x: (self.frame.width - kScale*125)/2, y: (self.frame.height - kScale*40)/2, width: kScale*125, height: kScale*40)
            replayBtn.frame = CGRect(x: (self.frame.width - kScale*80)/2, y: (self.frame.height - kScale*80)/2, width: kScale*80, height: kScale*80)
        }
        layoutIfNeededVolumeAndbrightness()     //重新布局音量和l亮度控件
        self.layoutIfNeeded()
    }
    
    // MARK: 双击屏幕播放暂停按钮
    func addReplayAdnPlayOrPauseButton() -> Void {
        //暂停按钮
        self.addSubview(playOrPauseBtn)
        //重播按钮
        self.addSubview(replayBtn)
    }
    
    // MARK: 添加屏幕点击拖动手势
    func addGestureRecognizer() -> Void {
        
        self.addGestureRecognizer(singleTapGesture)     //单击手势
        self.addGestureRecognizer(doubleTapGesture)     //双击手势
        self.addGestureRecognizer(panGesture)           //滑动手势
        // 解决点击当前view时候响应其他控件事件
        singleTapGesture.delaysTouchesBegan = true
        doubleTapGesture.delaysTouchesBegan = true
        panGesture.delaysTouchesBegan = true
        panGesture.delaysTouchesEnded = true
        panGesture.cancelsTouchesInView = true
        // 双击，滑动 ，失败响应单击事件,
        singleTapGesture.require(toFail: doubleTapGesture)
        singleTapGesture.require(toFail: panGesture)
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
        
        setupAVPlayer()                     //布局UI
        setupBottomBarView()                //添加底部控制Bar
        setupTopBarView()                   //添加顶部控制Bar
        addGestureRecognizer()              //添加手势
        addReplayAdnPlayOrPauseButton()     //添加暂停和播放按钮
        setupHideSystemVolume()             //隐藏系统音量UI
        layoutIfNeededVolumeAndbrightness() //重新布局音量和l亮度控件
        volumeChangesListener()             //添加音量监听
        addNotificationCenter()             //添加前后台切换监听
        
    }
    
}

