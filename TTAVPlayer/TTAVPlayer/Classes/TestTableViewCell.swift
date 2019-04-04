//
//  TestTableViewCell.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/4/4.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TestTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setuUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setuUI() -> Void {
        let path = Bundle.main.path(forResource: "01-课程安排", ofType: "mp4")
        
        //    let ttPlayer = TTAVPlayer.init(frame: CGRect(x: 0, y: 80, width: kScreemWidth, height: 180))
        let ttPlayer = TTAVPlayer.init(frame: CGRect(x: 0, y: 80, width: kScreemWidth, height: 180), self.contentView)
        ttPlayer.urlString = path!
        ttPlayer.videoName = "01-课程安排"
        ttPlayer.isHiddenTopBar = true
        //    ttPlayer.isHiddenTopBarMoreButton = true
        //    ttPlayer.isHiddenTopBarVideoName = true
        ttPlayer.isPlayingInBackground = true
        //        ttPlayer.delegate = self
        ttPlayer.ttPlayerFullScreen = TTPlayerFullScreen.notFullScreen
    }
}
