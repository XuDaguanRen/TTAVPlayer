//
//  TTTestViewController1.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/4/3.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTTestViewController1: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let path = Bundle.main.path(forResource: "01-课程安排", ofType: "mp4")
        
        //    let ttPlayer = TTAVPlayer.init(frame: CGRect(x: 0, y: 80, width: kScreemWidth, height: 180))
        let ttPlayer = TTAVPlayer.init(frame: CGRect(x: 0, y: 80, width: kScreemWidth, height: 180), cell.contentView)
        ttPlayer.urlString = path!
        ttPlayer.videoName = "01-课程安排"
        ttPlayer.isHiddenTopBar = true
        //    ttPlayer.isHiddenTopBarMoreButton = true
        //    ttPlayer.isHiddenTopBarVideoName = true
        ttPlayer.isPlayingInBackground = true
//        ttPlayer.delegate = self
        ttPlayer.ttPlayerFullScreen = TTPlayerFullScreen.notFullScreen
        
        return cell
    }
    
    func setupUI() -> Void {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
    }
}
