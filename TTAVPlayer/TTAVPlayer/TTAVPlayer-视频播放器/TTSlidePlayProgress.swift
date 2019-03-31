//
//  TTSlidePlayProgress.swift
//  TTAVPlayer
//
//  Created by macsss on 2019/3/31.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTSlidePlayProgress: UIView {
    
    /// 播放了多少时间
    var playTimeValue: String = "00:00" {
        didSet {
            playProgressTitleLab.text = playTimeValue
        }
    }
    
    /// 最小值
    var minimumValue: Float = 0.0 {
        didSet {
            playProgressSlider.maximumValue = self.minimumValue
        }
    }
    
    /// 最大值
    var maximumValue: Float = 0.0 {
        didSet {
            playProgressSlider.maximumValue = self.maximumValue
        }
    }
    
    /// 当前值
    var value: Float = 0.0 {
        didSet {
            playProgressSlider.value = self.value
        }
    }
    
    /// 亮度文案
    lazy var playProgressTitleLab: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 32)
        lable.textColor = UIColor.init(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        lable.textAlignment = .center
        return lable
    }()
    
    lazy var playProgressSlider: TTSlider = {
        let progressSlider = TTSlider()
        progressSlider.ttHeight = 1.5
        return progressSlider
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPlayProgressUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayProgressUI() -> Void {
        
        playProgressTitleLab.frame = CGRect(x: 5, y: 5, width: self.frame.width - 10, height: self.frame.height - 30)
        playProgressTitleLab.text = playTimeValue
        addSubview(playProgressTitleLab)
        
        playProgressSlider.frame = CGRect(x: 10, y: self.frame.height - 20, width: self.frame.width - 20, height: 10)
        playProgressSlider.isEnabled = false
        playProgressSlider.layer.masksToBounds = true
        playProgressSlider.layer.cornerRadius = 15
        playProgressSlider.backgroundColor = UIColor.clear
        playProgressSlider.thumbTintColor = UIColor.clear
        playProgressSlider.setThumbImage(UIImage.init(named: "player_progress_slider_n"), for: .normal)
        playProgressSlider.minimumTrackTintColor = UIColor.init(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        playProgressSlider.maximumTrackTintColor = UIColor.init(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        addSubview(playProgressSlider)
    }
}
