//
//  TTTestViewController1.swift
//  TTAVPlayer
//
//  Created by Maiya on 2019/4/3.
//  Copyright © 2019 Maiya. All rights reserved.
//

import Foundation
import UIKit

class TTTestViewController1: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
   
    var v  = UICollectionViewFlowLayout()
    
    
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
    
        return cell
    }
    
    func setupUI() -> Void {
        let tableView = UITableView.init(frame: self.view.bounds, style: .plain)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TestTableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(tableView)
    }
}
