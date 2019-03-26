//
//  TTBaseController.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/3/26.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTBaseController: UIViewController {
    //自定按钮
    lazy var callbackBtn = UIButton()
    //添加文件按钮
    lazy var navRighButton = UIButton()
    //标题title
    lazy var titleLabel = UILabel()
    //自定义NavgationBar
    lazy var ttNavigationBar  = UINavigationBar()
    
    var ttTitleString: String = "" {
        didSet {
            titleLabel.text = ttTitleString
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: pop上一个控制
    @objc private func popToParent() {
        //隐藏底部Bar
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupUI() -> Void {
        ttNavigationBar.frame = CGRect(x: 0, y: 0, width:kScreemWidth, height: kNavBarHeight)
        view.addSubview(ttNavigationBar)
        
        let titleX = kScreemWidth / 3
        let titleY = ttNavigationBar.bounds.height - kStatusbarHeigt - (1 * kScale)
        
        titleLabel.frame = CGRect(x: titleX, y: kStatusbarHeigt, width: titleX, height: titleY)
        titleLabel.font = UIFont.boldSystemFont(ofSize: fontSize19)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .center
        ttNavigationBar.addSubview(titleLabel)
        
        callbackBtn.frame = CGRect(x: kScale * 10 , y: kStatusbarHeigt, width: titleX - 50, height: titleY)
        //        callbackBtn.setImage(UIImage.init(named: "tt_callback_icon"), for: .normal)
        callbackBtn.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: -kScale*30, bottom: 0, right: 0)
        callbackBtn.setTitle("  返回", for: .normal)
        callbackBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize18)
        callbackBtn.setTitleColor(UIColor.blue, for: .normal)
        callbackBtn.addTarget(self, action: #selector(popToParent), for: .touchUpInside)
        callbackBtn.isHidden = false
        ttNavigationBar.addSubview(callbackBtn)
        
    }
}
