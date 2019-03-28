//
//  TTPlayerOrientation.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/28.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

public enum TTOrientationSupport: Int {
    case orientationPortrait        //正常状态
    case orientationRight           //全屏向右侧旋转
    case orientationAll             //兼容上下左右
    
    //获取屏幕的支持方向
    public func getOrientSupports() -> UIInterfaceOrientationMask {
        switch self {
        case .orientationPortrait:
            return [.portrait]
        case .orientationRight:
            return [.landscapeRight]
        case .orientationAll:
            return [.portrait, .landscapeLeft, .landscapeRight]
        }
    }
}

/// 手机屏幕锁支持方向 默认为只是上下正常方向
public var tt_OrientationSupport: TTOrientationSupport = .orientationPortrait
