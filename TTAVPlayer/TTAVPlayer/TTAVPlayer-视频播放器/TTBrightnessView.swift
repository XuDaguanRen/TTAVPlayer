//
//  TTBrightnessView.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/4/1.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTBrightnessView: UIView {
    
    /// 亮度图片
    lazy var brightnessImage: UIImageView = {
        let imageV = UIImageView()
        return imageV
    }()
    
    /// 亮度文案
    lazy var brightnessTitleLab: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.boldSystemFont(ofSize: 16)
        lable.textColor = UIColor.darkText
        lable.textAlignment = .center
        lable.text = "亮度"
        return lable
    }()
    
    /// 底部背景京View
    lazy var brightnessSliderBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkText
        return view
    }()
    
    /// 提示亮度View
    lazy var tipsViewArray: [UIView] = {
        let tips = [UIView]()
        return tips
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius  = 10
        self.layer.masksToBounds = true //
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTTBrightness(_ value: CGFloat) {
        //        print("当前亮度是多少\(UIScreen.main.brightness)")
        UIScreen.main.brightness -= value
        let brightness = UIScreen.main.brightness  //当前亮度
        let stage = 1.0/16.0 //一共有15个格子
        let level = brightness / CGFloat(stage)  //当前亮度除以 所有格子的亮度比例 得到当前应该显示到哪一格
        for index in 0..<self.tipsViewArray.count {
            let tipsView = self.tipsViewArray[index]
            
            if index <= Int(level) {
                if level < 0.8 { //0.8 是最后一个白色tipsView
                    tipsView.isHidden = true
                } else {
                    tipsView.isHidden = false
                }
            } else {
                tipsView.isHidden = true
            }
        }
    }
    
    // MARK: 布局进度调View
    func tt_CreateTipsViews() -> Void {
        
        let tipWidth = (brightnessSliderBackView.bounds.size.width - 17.0)/16.0 // 每个TIPS间隔1
        let tipHight: CGFloat = 5
        let tipY: CGFloat = 1
        for index in 0..<16 {
            let tipsX = CGFloat(index) * (tipWidth + 1) + 1
            let tipsView = UIView()
            tipsView.backgroundColor = UIColor.white
            tipsView.frame = CGRect(x: tipsX, y: tipY, width: tipWidth, height: tipHight)
            
            self.brightnessSliderBackView.addSubview(tipsView)
            self.tipsViewArray.append(tipsView)
        }
    }
    
    // MARK: 布局UI
    fileprivate func setupUI() -> Void {
        
        //  效果视图（效果为模糊）
        let blurEffect = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = self.bounds
        
        // 设置透明度
        effectView.alpha = 0.8
        addSubview(effectView)
        
        brightnessTitleLab.frame = CGRect(x: 0, y: 10, width: self.frame.width, height: 20)
        brightnessTitleLab.textColor = UIColor.init(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        self.addSubview(brightnessTitleLab)
        
        brightnessImage.frame = CGRect(x: (self.frame.size.width - 80)/2, y: (self.frame.size.height - 80)/2 + 3 , width: 80, height: 80)
        brightnessImage.image = UIImage.init(named: "player_brightness")
        self.addSubview(brightnessImage)
        
        brightnessSliderBackView.frame = CGRect(x: 15, y: self.frame.size.height - 23 , width: self.frame.size.width - 30, height: 7)
        brightnessSliderBackView.backgroundColor = UIColor.init(red: 92/255, green: 92/255, blue: 92/255, alpha: 1)
        self.addSubview(brightnessSliderBackView)
        
        //布局底部进度显示View
        tt_CreateTipsViews()
    }
    
}
