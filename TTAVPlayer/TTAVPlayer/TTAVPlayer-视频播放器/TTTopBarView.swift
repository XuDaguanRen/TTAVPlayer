//
//  TTTopBarView.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/28.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

// MARK: - 枚举
/// 播放是否全屏
///
/// - normal: 正常状态
/// - full: 全屏状态
enum TTPlayTopBarType {
    case Normal
    case Full
}

// MARK: - 代理
protocol TTTopBarDelegate: NSObjectProtocol {
    
    // MARK: 更多按钮回调
    func tt_ClickTopBarMoreButton() -> Void
    
    // MARK: 返回按钮回调
    func tt_ClickTopBarBackButton() -> Void
}

class TTTopBarView: UIView {
    // MARK: - 属性
    /// 代理
    weak var delegate: TTTopBarDelegate?
    /// 返回按钮
    fileprivate var backButton: UIButton?
    /// 更多按钮
    fileprivate var moreButton: UIButton?
    /// 视频名称
    lazy var videoNameLable: UILabel = {
        let lable = UILabel()
        lable.textColor = .white
        lable.font = UIFont.systemFont(ofSize: 15)
        lable.textAlignment = .left
        return lable
    }()
    /// 视频名称String
    var videoNameString: String = "" {
        didSet {
            videoNameLable.text = self.videoNameString
        }
    }
    /// 是否是全屏状态
    var isFullScreen: TTPlayTopBarType? {
        didSet {
            if self.isFullScreen == TTPlayTopBarType.Full {
                ttLayoutIfNeededFullTopBarView()
            } else {
                ttLayoutIfNeededNormalTopBarView()
            }
            self.layoutIfNeeded()
        }
    }
    /// 是否隐藏顶部Bar控制面板
    var isHiddenTopBar: Bool = true {
        didSet {    //竖屏默认隐藏
            self.isHidden = isHiddenTopBar
        }
    }
    /// 毛玻璃效果
    fileprivate var effectView = UIVisualEffectView.init()
    
    // MARK: - 重写初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        //布局UI
        setupTopControlBarViewUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: 修改布局 全屏
    @objc func ttLayoutIfNeededFullTopBarView() -> Void {
        // 返回按钮
        backButton?.frame = CGRect(x: 0, y: 0, width: kScale * 50, height: self.frame.height)
        videoNameLable.frame = CGRect(x: backButton!.right + kScale * 10, y: 0, width: self.frame.width - (kScale * 50) * 2 + kScale * 20, height: self.frame.height)
        moreButton?.frame = CGRect(x: self.frame.width - kScale * 50, y: 0, width: kScale * 50, height: self.frame.height)
        effectView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    // MARK: 修改布局 正常
    @objc func ttLayoutIfNeededNormalTopBarView() -> Void {
        // 返回按钮
        backButton?.frame = CGRect(x: 0, y: 0, width: kScale * 50, height: self.frame.height)
        videoNameLable.frame = CGRect(x: backButton!.right + kScale * 10, y: 0, width: self.frame.width - (kScale * 50) * 2 + kScale * 20, height: self.frame.height)
        moreButton?.frame = CGRect(x: self.frame.width - kScale * 50, y: 0, width: kScale * 50, height: self.frame.height)
        effectView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    // MARK: 布局UI
    func setupTopControlBarViewUI() -> Void {
        
        //  效果视图（效果为模糊）
        let blurEffect = UIBlurEffect.init(style: .light)
        effectView = UIVisualEffectView(effect: blurEffect)
        effectView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        // 设置透明度
        effectView.alpha = 0.35
        self.addSubview(effectView)
        
        // 返回按钮
        backButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: kScale * 50, height: self.frame.height))
        backButton?.setImage(UIImage.init(named: "player_icon_nav_back"), for: .normal)
        backButton?.addTarget(self, action: #selector(clickTopBarBackButton), for: .touchUpInside)
        
        self.addSubview(backButton!)
        
        videoNameLable.frame = CGRect(x: backButton!.right + kScale * 10, y: 0, width: self.frame.width - (kScale * 50) * 2 + kScale * 20, height: self.frame.height)
        videoNameLable.text = videoNameString
        self.addSubview(videoNameLable)
        
        // 更多按钮
        moreButton = UIButton.init(frame: CGRect(x: self.frame.width - kScale * 50, y: 0, width: kScale * 50, height: self.frame.height))
        moreButton?.setImage(UIImage.init(named: "player_icon_more"), for: .normal)
        moreButton?.addTarget(self, action: #selector(clickTopBarMoreButton), for: .touchUpInside)
        
        self.addSubview(moreButton!)
    }
    
}

extension TTTopBarView {
    
    // MARK: 更多按钮按钮
    @objc func clickTopBarMoreButton() -> Void {
        if let delegate = delegate {
            delegate.tt_ClickTopBarMoreButton()
        }
    }
    
    // MARK: 返回按钮
    @objc func clickTopBarBackButton() -> Void {
        if let delegate = delegate {
            delegate.tt_ClickTopBarBackButton()
        }
    }
    
}
