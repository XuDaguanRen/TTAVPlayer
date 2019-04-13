//
//  TTRefs.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/25.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTRefs: NSObject {
    
    /// 本地数据单利
    static let share = TTRefs()
    
    // MARK: - 获取状态栏高度
    func statusBarHeight() -> CGFloat {
        let statusBar = UIApplication.shared.statusBarFrame.size.height
        return statusBar
    }
    
    // 设备型号
    func isiPad() -> Bool {
        if UIDevice.current.model == "iPad" {
            return true
        } else {
            return false
        }
    }
    
}
