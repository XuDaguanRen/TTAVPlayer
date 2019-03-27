//
//  TTView+Extension.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

enum Direction {
    case top
    case left
    case bottom
    case right
}

extension UIView {
    
    /// 尺寸
    var size: CGSize {
        get {
            return self.frame.size
        }
        set(newValue) {
            self.frame.size = CGSize(width: newValue.width, height: newValue.height)
        }
    }
    
    /// 宽度
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set(newValue) {
            self.frame.size.width = newValue
        }
    }
    
    /// 高度
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set(newValue) {
            self.frame.size.height = newValue
        }
    }
    
    /// 横坐标
    var x: CGFloat {
        get {
            return self.frame.minX
        }
        set(newValue) {
            self.frame = CGRect(x: newValue, y: y, width: width, height: height)
        }
    }
    
    /// 纵坐标
    var y: CGFloat {
        get {
            return self.frame.minY
        }
        set(newValue) {
            frame.origin.x = newValue - frame.size.width
        }
    }
    
    /// 中心横坐标
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set(newValue) {
            center.x = newValue
        }
    }
    
    /// 中心纵坐标
    var centerY: CGFloat {
        get {
            return center.y
        }
        set(newValue) {
            center.y = newValue
        }
    }
    
    /// 原点
    var origin: CGPoint {
        get {
            return frame.origin
        }
        set(newValue) {
            frame.origin = newValue
        }
    }
    
    //上边
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
    }
    
    //左边
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
    }
    
    //下边
    var bottom: CGFloat {
        get {
            return self.frame.origin.y + self.bounds.height
        }
    }
    
    //右边
    var right: CGFloat {
        get {
            return self.frame.origin.x + self.bounds.width
        }
    }
    
}
