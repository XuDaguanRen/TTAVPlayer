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
    case full
    case normal
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
    var backButton: UIButton?
    /// 更多按钮
    var moreButton: UIButton? 
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
            if self.isFullScreen == TTPlayTopBarType.full {
                ttLayoutIfNeededFullTopBarView()
            } else {
                ttLayoutIfNeededNormalTopBarView()
            }
            self.layoutIfNeeded()
        }
    }
    /// 播放栏背景蒙版
    fileprivate var barMaskImageView = UIImageView.init(image: UIImage.init(named: "miniplayer_mask_top"))
    
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
        backButton?.frame = CGRect(x: 0, y: 0, width: self.frame.height + kScale * 10, height: self.frame.height - kScale * 10)
        videoNameLable.frame = CGRect(x: backButton!.right + kScale * 10, y: 0, width: self.frame.width - (self.frame.height + kScale * 10) * 2 - kScale * 20, height: self.frame.height - kScale * 10)
        moreButton?.frame = CGRect(x: videoNameLable.right + kScale * 10, y: 0, width: self.frame.height + kScale * 10, height: self.frame.height - kScale * 10)
        barMaskImageView.frame = self.bounds
    }
    
    // MARK: 修改布局 正常
    @objc func ttLayoutIfNeededNormalTopBarView() -> Void {
        // 返回按钮
        backButton?.frame = CGRect(x: 0, y: 0, width: self.frame.height + kScale * 10, height: self.frame.height)
        videoNameLable.frame = CGRect(x: backButton!.right + kScale * 10, y: 0, width: self.frame.width - (self.frame.height + kScale * 10) * 2 - kScale * 20, height: self.frame.height)
        moreButton?.frame = CGRect(x: videoNameLable.right + kScale * 10, y: 0, width: self.frame.height + kScale * 10, height: self.frame.height)
        barMaskImageView.frame = self.bounds
    }
    
    // MARK: 布局UI
    private func setupTopControlBarViewUI() -> Void {
        
        barMaskImageView.frame = self.bounds
        self.addSubview(barMaskImageView)
        
        // 返回按钮
        backButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: self.frame.height + kScale * 10, height: self.frame.height))
        backButton?.setImage(UIImage.init(named: "player_icon_nav_back"), for: .normal)
        backButton?.addTarget(self, action: #selector(clickTopBarBackButton), for: .touchUpInside)
        
        self.addSubview(backButton!)
        
        videoNameLable.frame = CGRect(x: backButton!.right + kScale * 10, y: 0, width: self.frame.width - (self.frame.height + kScale * 10) * 2 - kScale * 20, height: self.frame.height)
        videoNameLable.text = videoNameString
        self.addSubview(videoNameLable)
        
        // 更多按钮
        moreButton = UIButton.init(frame: CGRect(x:  videoNameLable.right + kScale * 10, y: 0, width: self.frame.height + kScale * 10, height: self.frame.height))
        moreButton?.setImage(UIImage.init(named: "player_icon_more"), for: .normal)
        moreButton?.addTarget(self, action: #selector(clickTopBarMoreButton), for: .touchUpInside)
        
        self.addSubview(moreButton!)
    }
    
}

// MARK: - 方法实现
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
