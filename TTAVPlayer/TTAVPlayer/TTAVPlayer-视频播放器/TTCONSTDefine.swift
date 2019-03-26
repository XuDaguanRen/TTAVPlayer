//
//  TTCONSTHeader.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/25.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

/// 屏幕宽高
let kScreemWidth = UIScreen.main.bounds.width
let kScreemHeigh = UIScreen.main.bounds.height

/// 缩放比例
let kScale =  UIScreen.main.bounds.width / (TTRefs.share.isiPad() ? 768.0 : 375 )
/// 状态栏高度 如果程序启动时隐藏状态栏，则获取不到高度
let kStatusbarHeigt = TTRefs.share.statusBarHeight()
/// Nav高度
let kNavBarHeight = kStatusbarHeigt + 44.0
/// 底部安全高度
let kSafeAreaHeight = kStatusbarHeigt > 20.0 ? 34.0 : 0.0
/// 底部Bar高度
let kTabBarHeight = CGFloat(kSafeAreaHeight + 49.0)

/// 缩放字号
let fontSize20 = 20 * kScale
let fontSize19 = 19 * kScale
let fontSize18 = 18 * kScale
let fontSize16 = 16 * kScale
let fontSize15 = 15 * kScale
let fontSize14 = 14 * kScale
