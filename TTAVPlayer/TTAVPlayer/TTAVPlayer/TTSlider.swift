//
//  TTSlider.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/27.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Block回调
typealias tt_SliderTouchesEndedBlock = (_ slider: UISlider) -> Void

class TTSlider: UISlider {
    // MARK: - 属性
    /// Slider进度条高度
    var ttHeight: CGFloat = 0.0
    //记录大小
    private var lastBounds = CGRect.init()
    /// 按钮滑动结束回调
    var sliderTouchesEndedBlock: tt_SliderTouchesEndedBlock?
    
    // MARK: - 重载写方法
    override func minimumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    
    override func maximumValueImageRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
    
    // MARK: 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.trackRect(forBounds: bounds)
        return CGRect.init(x: rect.origin.x, y: (bounds.size.height - ttHeight) / 2, width: bounds.size.width, height: ttHeight)
    }
    
    // MARK: 改变滑块的触摸范围
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        
        var tempRect = rect
        tempRect.origin.y = rect.origin.y + 10
        tempRect.size.width =  rect.size.width + 20
        tempRect = super.thumbRect(forBounds: rect, trackRect: rect, value: value)
        lastBounds = tempRect //记录最终的数据
        return tempRect
    }
    
    // MARK: 重写点击结束方法 添加回调给外部使用
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.sliderTouchesEndedBlock != nil {
            self.sliderTouchesEndedBlock!(self)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var resultView = super.hitTest(point, with: event)
        
        if resultView == self {
            /*如果这个view是self,我们给slider扩充一下响应范围,
             这里的扩充范围数据就可以自己设置了
             */
            
            if (point.y >= -15) && (point.y < (lastBounds.size.height + 30)) && (point.x >= 0 && point.x < self.bounds.width) {
                resultView = self
            }
        }
        return resultView;
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var result = super.point(inside: point, with: event)
        
        if result {
            //同理,如果在slider范围类,扩充响应范围
            if (point.y >= (lastBounds.origin.x - 30)) && (point.x <= (lastBounds.origin.x + lastBounds.size.width + 30)) && (point.y >= -40) && (point.y < (lastBounds.size.height + 40)) {
                result = true
            }
        }
        return result
    }
}
