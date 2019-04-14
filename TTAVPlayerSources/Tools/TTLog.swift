//
//  TTLog.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/25.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation

/// 日志输出功能
///
/// - Parameters:
///   - message: （T表示不指定日志信息参数类型）
///   - file: 文件描述
///   - function: 文件类名
///   - line: 打印行号
func TTLog<T>(_ message:T, file:String = #file, function:String = #function, line:Int = #line) {
    #if DEBUG
    //获取文件名
    let fileName = (file as NSString).lastPathComponent
    let gFormatter = DateFormatter()
    gFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let timestamp = gFormatter.string(from: Date())
    //打印日志内容
    print("✅ [\(timestamp)] <\(fileName)> [line:\(line)]: \(message)")
    #endif
}
