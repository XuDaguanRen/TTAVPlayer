//
//  TTAVPlayer.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MediaPlayer

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
    
    /// 锁定屏幕播放 下一首
    @objc optional func tt_avPlayerLockScreenNextTrack() -> Void
    
    /// 锁定屏幕播放 上一首
    @objc optional func tt_avPlayerLockScreenPreviousTrack() -> Void
    
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
                if isDefaultFullScreen {
                    DispatchQueue.main.async {
                        self.tt_DefaultiSFullScreen()        //默认全屏播放
                    }
                }
            }
        }
    }
    /// 滑动方向枚举
    private var ttPanDirection: TTPanDirection?     //滑动手势的方向
    /// 记录初始大小
    private var ttFrame: CGRect?
    /// 记录父视图 视频全屏播放后返回初始播放
    private var ttContainerView: UIView?
    /// 记录父视图 视频全屏播放后返回初始播放
    private var ttContainerVC: UIViewController?
    /// 播放器
    private lazy var avPlayerView: TTAVPlayerView? = {
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
    private lazy var bottomBarView: TTBottomBarView = {
        //底部播放 暂定 快进 全屏播放工具条
        let bottomBar = TTBottomBarView.init(frame: CGRect(x: 0, y: self.frame.size.height - kScale * 50, width: self.bounds.width, height: kScale * 50), sliderHeight: kScale * 30)
        return bottomBar
    }()
    /// 是否是全屏
    private var isOrientation : Bool = false
    /// 顶部Bar控制View
    private lazy var topBarView: TTTopBarView = {
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
    private lazy var singleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(singleTapGestureRecognizers(_:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    /// 双击手势
    private lazy var doubleTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(doubleTapGestureRecognizers(_:)))
        gesture.numberOfTapsRequired = 2
        gesture.numberOfTouchesRequired = 1
        return gesture
    }()
    /// 滑动手势
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(panGestureRecognizers(_:)))
        gesture.delegate = self
        gesture.maximumNumberOfTouches = 1
        gesture.isEnabled = false          //先让手势不能触发 全屏的时候在触发手势
        return gesture
    }()
    /// 是否隐藏bar
    private var topAndBottomBarHidden: Bool = false
    /// 暂停提示按钮
    private lazy var playOrPauseBtn: UIButton = {
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
    private lazy var replayBtn: UIButton = {
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
    private var isPausePlay: Bool = false
    /// 滑动播放显示进度控件
    private lazy var slidePlayProgress: TTSlidePlayProgress = {
        let slideProgress = TTSlidePlayProgress.init(frame: CGRect(x: (self.frame.width - kScale*160)/2, y: (self.frame.height - kScale*80)/2 - kScale*20, width: kScale*160, height: kScale*80))
        slideProgress.backgroundColor = UIColor.clear
        return slideProgress
    }()
    private var slidingTime: CGFloat?               //记录当前已经播放的时间
    /// 音量显示
    private lazy var volumeSlider: TTMPVolumeView = {
        let volumeView = TTMPVolumeView.init(frame: CGRect(x: 0, y: 0, width: kScale*180, height: kScale*180))
        volumeView.backgroundColor = UIColor.init(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.9)
        return volumeView
    }()
    /// 是否是屏幕滑动修改音量
    private var isScreenChangeVolume: Bool = false
    /// 亮度显示
    private var brightnessSlider: TTBrightnessView = {
        let brightView = TTBrightnessView.init(frame: CGRect(x: 0, y: 0, width: kScale*180, height: kScale*180))
        brightView.backgroundColor = UIColor.init(red: 225/255, green: 225/255, blue: 225/255, alpha: 0.9)
        return brightView
    }()
    /// 在前后台切换时记录播放状态
    private var beforeChangePlayerStatus: TTAVPlayerStatus?
    /// 是否在后台时继续播放
    public var isPlayingInBackground: Bool?
    /// 是否是全屏
    public var isDefaultFullScreen: Bool = false {
        didSet {
            if isDefaultFullScreen {
                bottomBarView.isHidden = true
                topBarView.isHidden = true
            }
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
        containerVC?.view.backgroundColor = UIColor.black
        containerView?.backgroundColor = UIColor.black
        ttContainerVC = containerVC
        ttContainerView = containerView
        ttFrame = frame
        
        setupTTAVPlayerUI()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()    
        TTLog("didMoveToWindow 视图将要出现")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        removeAVPlayer(isFullScreenBack: false)
        TTLog("didMoveToSuperview视图已经消失")
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        removeAVPlayer(isFullScreenBack: false)
        TTLog("didMoveToSuperview视图已经消失")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeOutputVolume()  //注销音量监听
    }
    
    // MARK: 销毁通知
    
    /// 销毁通知
    ///
    /// - Parameter isFullScreenBack: 是全屏返回
   private func removeAVPlayer(isFullScreenBack: Bool) -> Void {
        
        /*
         视图销毁逻辑：如果是默认全屏状态，只有调用全屏左侧上部返回按钮时才销毁播放器，如果是不是默认全屏状态，从别的界面push过来时，当Navgation栈中没有当前控制器时销毁播放器，
         还差一个单独在View上播放的销毁时间没有写，稍后加上………………
         */
        
        if isDefaultFullScreen {
            if isFullScreenBack {
                NotificationCenter.default.removeObserver(self)
                self.avPlayerView?.ttPlayerStatu = TTPlayerStatus.Pause
                self.removeFromSuperview()
                self.avPlayerView?.removeFromSuperview()
                self.avPlayerView = nil
                self.ttContainerVC = nil
            }
        } else {
            if let containerVC = ttContainerVC {
                if ((containerVC.navigationController?.viewControllers.count) != nil) {
                    if !(containerVC.navigationController?.viewControllers.contains(containerVC))! {
                        TTLog("传进来的控制器不在了在Nav栈区")
                        NotificationCenter.default.removeObserver(self)
                        self.avPlayerView?.ttPlayerStatu = TTPlayerStatus.Pause
                        self.removeFromSuperview()
                        self.avPlayerView?.removeFromSuperview()
                        self.avPlayerView = nil
                        self.ttContainerVC = nil
                    }
                } else {
                    NotificationCenter.default.removeObserver(self)
                    self.avPlayerView?.ttPlayerStatu = TTPlayerStatus.Pause
                    self.removeFromSuperview()
                    self.avPlayerView?.removeFromSuperview()
                    self.avPlayerView = nil
                    self.ttContainerVC = nil
                }
            }
        }
        
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
    private func layoutIfNeededVolumeAndbrightness() -> Void {
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
    private func setupHideSystemVolume() -> Void {
        guard let containerVC = ttContainerVC else { return }
        //隐藏了系统的声音View 使用自定义的 如果系统的音量控制不加载到控制器中 这中隐藏方法不起作用
        let volumeView = TTMPVolume.init(frame: CGRect(x: -1000, y: -1000, width: 155, height: 155))
        containerVC.view.addSubview(volumeView)
    }
    
    // MARK: 重置子视图布局
    private func setupResetSubviewLayout() -> Void {
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
    private func addReplayAdnPlayOrPauseButton() -> Void {
        //暂停按钮
        self.addSubview(playOrPauseBtn)
        //重播按钮
        self.addSubview(replayBtn)
    }
    
    // MARK: 添加屏幕点击拖动手势
    private func addGestureRecognizer() -> Void {
        
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
    private func setupTopBarView() -> Void {
        topBarView.delegate = self
        topBarView.backgroundColor = UIColor.clear
        self.addSubview(topBarView)
    }
    
    // MARK: 布局底部播放控制View按钮SliderView
    private func setupBottomBarView() -> Void {
        //底部播放 暂定 快进 全屏播放工具条
        bottomBarView.delegate = self
        bottomBarView.backgroundColor = UIColor.clear
        self.addSubview(bottomBarView)
    }
    
    // MARK: 布局AVPlayer播放器
    private func setupAVPlayer() -> Void {
        
        //视频播放器
        avPlayerView?.delegate = self    //设置代理
        self.addSubview(avPlayerView!)
    }
    
    // MARK: - 布局TTAVPlayerUI
    private func setupTTAVPlayerUI() -> Void {
        
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

// MARK: - 设置后台播放显示信息
extension TTAVPlayer {
    
    // 设置后台播放显示信息
    private func configMediaItemArtwork() -> Void {
        let mpic = MPNowPlayingInfoCenter.default()
        
        //专辑封面
        let mySize = CGSize(width: 100, height: 100)
        var albumArt: Any?
        if #available(iOS 10.0, *) {
            albumArt = MPMediaItemArtwork(boundsSize:mySize) { sz in
                return UIImage(named: "player_brightness")!
            }
        } else {
            // Fallback on earlier versions
        }
        
        //获取进度
        let postion = String(describing: Double(bottomBarView.value))
        let duration = String(describing: Double(bottomBarView.maximumValue))
        
        mpic.nowPlayingInfo = [MPMediaItemPropertyTitle: "",
                               MPMediaItemPropertyArtist: "",
                               MPMediaItemPropertyArtwork: albumArt as Any, //显示的图片
            MPNowPlayingInfoPropertyElapsedPlaybackTime: postion,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0] //播放速率
        
    }
    
    //是否能成为第一响应对象
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: 重写后台播放控制
    override func remoteControlReceived(with event: UIEvent?) {
        super.remoteControlReceived(with: event)
        
        guard let event = event else {
            return
        }
        if event.type == UIEvent.EventType.remoteControl {
            switch event.subtype {
            case .remoteControlPlay: //播放
                ttAVPlayerStatus = TTAVPlayerStatus.Playing
                break
            case .remoteControlPause:   //暂停
                ttAVPlayerStatus = TTAVPlayerStatus.Pause
                break
            case .remoteControlStop: //停止
                break
            case .remoteControlTogglePlayPause: //切换播放暂停（耳机线控）
                break
            case .remoteControlNextTrack: //下一首
                //下一首回调
                if let ttDelegate = delegate {
                    ttDelegate.tt_avPlayerLockScreenNextTrack?()
                }
                break
            case .remoteControlPreviousTrack: //上一首
                //上一首回调
                if let ttDelegate = delegate {
                    ttDelegate.tt_avPlayerLockScreenPreviousTrack?()
                }
                break
            case .remoteControlBeginSeekingBackward: //开始快退
                break
            case .remoteControlEndSeekingBackward: //结束快退
                break
            case .remoteControlBeginSeekingForward: //开始快进
                break
            case .remoteControlEndSeekingForward:  //结束快进
                break
            default:
                break
            }
        }
    }
    
}

// MARK: - APP将要被挂起 前后台切换处理
extension TTAVPlayer {
    
    // MARK: APP将要被挂起
    ///
    /// - Parameter sender: 记录被挂起前的播放状态，进入前台时恢复状态
    @objc private func tt_ApplicationWillResignActive(_ sender: NSNotification) -> Void {
        //如果设置后台可以播放
        if isPlayingInBackground == true {
            avPlayerView?.removePlayerOnPlayerLayer()
        } else {
            beforeChangePlayerStatus = ttAVPlayerStatus  // 记录下进入后台前的播放状态
            self.ttAVPlayerStatus = TTAVPlayerStatus.Pause         //暂停播放
        }
    }
    
    // MARK: APP进入前台，恢复播放状态
    ///
    /// - Parameter sender: 恢复记录被挂起前的播放状态
    @objc private func tt_ApplicationDidBecomeActive(_ sender: NSNotification) -> Void {
        //如果设置后台可以播放
        if isPlayingInBackground == true {
            avPlayerView?.resetPlayerToPlayerLayer()
        } else {
            if let oldStatus = beforeChangePlayerStatus {
                ttAVPlayerStatus = oldStatus
            } else {
                self.ttAVPlayerStatus = TTAVPlayerStatus.Pause   //暂停播放
            }
        }
    }
    
    // MARK: 添加App前后台切换通知
    private func addNotificationCenter() -> Void {
        // 注册APP被挂起 + 进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(tt_ApplicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tt_ApplicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}

// MARK: - 监听按键音量变化
extension TTAVPlayer {
    
    // MARK: 删除音量通知
    private func removeOutputVolume() {
        AVAudioSession.sharedInstance().removeObserver(self, forKeyPath: "outputVolume", context: nil)
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    // MARK: 监听手机侧键音量变化
    private func volumeChangesListener() -> Void {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback, options: AVAudioSession.CategoryOptions.defaultToSpeaker)    //设置可后台播放模式
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
    @objc private func removeVolumeView() -> Void {
        UIView.animate(withDuration: 1.2, animations: {
            self.volumeSlider.alpha = 0.0
        }) { (Bool) in
            self.volumeSlider.removeFromSuperview()
        }
    }
    
    // MARK: 删除亮度控制View
    @objc private func removeBrightnessView() -> Void {
        UIView.animate(withDuration: 1.2, animations: {
            self.brightnessSlider.alpha = 0.0
        }) { (Bool) in
            self.brightnessSlider.removeFromSuperview()
        }
    }
    
    // MARK: 调整音量和亮度
    private func volumeAndBrightnessVeloctyMoved(_ movedValue: CGFloat, _ isVolume: Bool) {
        if isVolume {
            volumeSlider.slidingModifyUpdateTTVolume(movedValue/10000)
        } else {
            brightnessSlider.updateTTBrightness(movedValue/10000)
        }
    }
    
    // MARK: 水平移动的距离视频跟随 滑动播放
    ///
    /// - Parameter slidingValue: 滑动的距离
    private func horizontalSlidingValue(_ slidingValue: CGFloat) -> CGFloat {
        
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
    @objc private func clickReplay() -> Void {
        avPlayerView?.playSpecifyLocation(sliderTime: 0.0)
        ttAVPlayerStatus = TTAVPlayerStatus.Playing        //点击重播按钮
        replayBtn.isHidden = true
        tt_TopAndBottomBarShow(0.2, true)
    }
    
    // MARK: 按住屏幕上下滑动修改音量和亮度手势
    @objc private func panGestureRecognizers(_ sender: UIPanGestureRecognizer) {
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
    @objc private func doubleTapGestureRecognizers(_ sender: UITapGestureRecognizer) {
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
    @objc private func singleTapGestureRecognizers(_ sender: UITapGestureRecognizer) {
        
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
    @objc private func tt_TopAndBottomBarShow(_ duration: TimeInterval, _ isHiddenBar: Bool) -> Void {
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
    @objc private func tt_TopAndBottomBarHidden(_ duration: TimeInterval) -> Void {
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
        
        //返回按钮回调
        if let ttDelegate = delegate {
            ttDelegate.tt_avPlayerTopBarBackButton?()
        }
        
        if isDefaultFullScreen {  //是默认全屏返回
            if let containerVC = ttContainerVC {
                weak var weakSelf = self
                containerVC.dismiss(animated: false) {
                    weakSelf!.removeAVPlayer(isFullScreenBack: true)
                    weakSelf!.removeFromSuperview()
                    weakSelf!.ttContainerVC = nil     //释放传入的控制器 不然返回时播放器不会释放
                    weakSelf!.tt_UIInterfaceOrientation(UIInterfaceOrientation.portrait)   //默认屏幕方向
                }
            }
            return
        }
        
        if isOrientation { //普通全屏返回
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
        } else { //不是全屏返回
            var index = 0
            if let containerVC = ttContainerVC {
                index = containerVC.navigationController?.viewControllers.lastIndex(of: containerVC) ?? 0
            }
            if index > 1 {
                ttContainerVC?.navigationController?.popViewController(animated: true)
            }
        }
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
    
    // MARK: 默认全屏播放
    func tt_DefaultiSFullScreen() -> Void {
        self.tt_UIInterfaceOrientation(UIInterfaceOrientation.landscapeRight)    //右边
        isOrientation = true
        setupResetSubviewLayout()       //重置子视图布局
        avPlayerView?.ttOrientationLeftAndRightAnimation()       //改变 playerLayer 大小
        bottomBarView.fullScreenPlayTitle = "倍速"
        topBarView.isFullScreen = TTPlayTopBarType.Full             //全屏状态
        bottomBarView.isFullScreen = TTPlayBottomBarType.Full       //全屏状态
        topBarView.isHidden = false
        topBarView.backButton?.isHidden = false
        topBarView.videoNameLable.isHidden = false
        topBarView.moreButton?.isHidden = false
        bottomBarView.isHidden = false
        tt_TopAndBottomBarShow(0.2, true)
        if let containerVC = ttContainerVC {
            if !containerVC.view.subviews.contains(self) { //此处代码这样写 是因为我懒得 在调整一个逻辑了
                containerVC.view.addSubview(self)
            }
        } else {
            UIApplication.shared.keyWindow?.addSubview(self)        //播放器加载到window 上
        }
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
        configMediaItemArtwork()
    }
}
