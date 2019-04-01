//
//  TTMPVolume.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/4/1.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import MediaPlayer

/// 音量控制组件只有添加到ViewController中才可以使用设置frame的方式隐藏系统的音量控制工具，如果不加载到控制器中，加载到View中时使用设置frame方式隐藏音量控制器，则没有效果
class TTMPVolume: MPVolumeView {
    
}
