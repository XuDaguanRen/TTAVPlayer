//
//  TTMPVolumeView.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/4/1.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import MediaPlayer

class TTMPVolumeView: UIView {
    /// 亮度图片
    private lazy var volumeImage: UIImageView = {
        let imageV = UIImageView()
        return imageV
    }()
    
    /// 亮度文案
    private lazy var volumeTitleLab: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.boldSystemFont(ofSize: 16)
        lable.textColor = UIColor.darkGray
        lable.textAlignment = .center
        lable.text = "音量"
        return lable
    }()
    
    /// 底部背景京View
    private lazy var volumeBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkGray
        return view
    }()
    
    /// 提示亮度View
    private lazy var tipsViewArray: [UIView] = {
        let tips = [UIView]()
        return tips
    }()
    
    /// 音量显示
    var volumeSlider: UISlider?
    private lazy var volumeView: TTMPVolume = {
        let volumeV = TTMPVolume.init(frame: CGRect(x: -1000, y: -1000, width: 155, height: 155))
        volumeV.alpha = 0.00001
        volumeV.showsVolumeSlider = false
        volumeV.showsRouteButton = false
        volumeSlider = nil //每次获取要将之前的置为nil
        for view in volumeV.subviews {
            if view.classForCoder.description() == "MPVolumeSlider" {
                if let vSlider = view as? UISlider {
                    volumeSlider = vSlider
                }
                break
            }
        }
        return volumeV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius  = 10
        self.layer.masksToBounds = true
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 获取系统音量控件 及大小
    private func configureSystemVolume() {
        let value = AVAudioSession.init().outputVolume
        TTLog("当前音量是多少\(AVAudioSession.init().outputVolume)")
        if value <= 0 {
            volumeSlider?.value = AVAudioSession.init().outputVolume
        }
        tipsViewAnimation()
    }
    
    func slidingModifyUpdateTTVolume(_ value: CGFloat) {
        volumeSlider?.value -= Float(value)
        let volumeValue = volumeSlider?.value
        let stage = 1.0/16.0 //一共有15个格子
        let level = Float(volumeValue!) / Float(stage)  //当前亮度除以 所有格子的亮度比例 得到当前应该显示到哪一格
        for index in 0..<self.tipsViewArray.count {
            let tipsView = self.tipsViewArray[index]
            
            if index <= Int(level) {
                if level < 0.6 { //0.8 是最后一个白色tipsView
                    volumeImage.image = UIImage.init(named: "tips_icon_sound_disable")
                    tipsView.isHidden = true
                } else {
                    volumeImage.image = UIImage.init(named: "tips_icon_sound_enable")
                    tipsView.isHidden = false
                }
            } else {
                tipsView.isHidden = true
            }
        }
    }
    
    func sideButtonModifyUpdateTTVolume(_ value: CGFloat, _ isScreenChangeVolume: Bool) {
        if isScreenChangeVolume { return }  //如果是屏幕滑动直接返回
        volumeSlider?.value = Float(value)
        let volumeValue = volumeSlider!.value
        let stage = 1.0/16 //一共有15个格子
        let level = Float(volumeValue) / Float(stage)  //当前亮度除以 所有格子的亮度比例 得到当前应该显示到哪一格
        for index in 0..<self.tipsViewArray.count {
            let tipsView = self.tipsViewArray[index]
            if index < Int(level)  {
                //                TTLog("音量volumeValue----------\(volumeValue)")
                if volumeValue < 0.01 { // 是最后一个白色tipsView 判断值
                    volumeImage.image = UIImage.init(named: "tips_icon_sound_disable")
                    tipsView.isHidden = true
                } else {
                    volumeImage.image = UIImage.init(named: "tips_icon_sound_enable")
                    tipsView.isHidden = false
                }
            } else {
                if volumeValue < 0.01 { // 是最后一个白色tipsView 判断值
                    volumeImage.image = UIImage.init(named: "tips_icon_sound_disable")
                    tipsView.isHidden = true
                }
                tipsView.isHidden = true
                
            }
        }
    }
    
   private func tipsViewAnimation() -> Void {
        let volumeValue = volumeSlider!.value
        let stage = 1.0/16 //一共有15个格子
        let level = Float(volumeValue) / Float(stage)  //当前亮度除以 所有格子的亮度比例 得到当前应该显示到哪一格
        for index in 0..<self.tipsViewArray.count {
            let tipsView = self.tipsViewArray[index]
            if index <= Int(level)  {
                if level < 0.8 { //0.6 是最后一个白色tipsView
                    volumeImage.image = UIImage.init(named: "tips_icon_sound_disable")
                    tipsView.isHidden = true
                } else {
                    volumeImage.image = UIImage.init(named: "tips_icon_sound_enable")
                    tipsView.isHidden = false
                }
            } else {
                tipsView.isHidden = true
            }
        }
    }
    
    // MARK: 布局进度调View
   private func tt_CreateVolumeTipsViews() -> Void {
        let tipWidth = (volumeBackView.bounds.size.width - 17.0)/16.0 // 每个TIPS间隔1
        let tipHight: CGFloat = 5
        let tipY: CGFloat = 1
        for index in 0..<16 {
            let tipsX = CGFloat(index) * (tipWidth + 1) + 1
            let tipsView = UIView()
            tipsView.backgroundColor = UIColor.white
            tipsView.frame = CGRect(x: tipsX, y: tipY, width: tipWidth, height: tipHight)
            
            self.volumeBackView.addSubview(tipsView)
            self.tipsViewArray.append(tipsView)
        }
    }
    
    // MARK: 布局UI
    private func setupUI() -> Void {
        
        //  效果视图（效果为模糊）
        let blurEffect = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = self.bounds
        
        // 设置透明度
        effectView.alpha = 0.8
        addSubview(effectView)
        
        volumeTitleLab.frame = CGRect(x: 0, y: 10, width: self.frame.width, height: 20)
        volumeTitleLab.textColor = UIColor.init(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        self.addSubview(volumeTitleLab)
        
        volumeImage.frame = CGRect(x: (self.frame.size.width - 80)/2, y: (self.frame.size.height - 80)/2 + 3 , width: 80, height: 80)
        volumeImage.image = UIImage.init(named: "tips_icon_sound_enable")
        self.addSubview(volumeImage)
        
        volumeBackView.frame = CGRect(x: 15, y: self.frame.size.height - 23 , width: self.frame.size.width - 30, height: 7)
        volumeBackView.backgroundColor = UIColor.init(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        self.addSubview(volumeBackView)
        self.addSubview(volumeView)   //音量控制加载到当前View
        //获取当前音量大小
        configureSystemVolume()
        
        //布局底部进度显示View
        tt_CreateVolumeTipsViews()
    }
    
}
