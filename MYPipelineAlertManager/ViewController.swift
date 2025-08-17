//
//  ViewController.swift
//  MYPipelineAlertManager
//
//  Created by ios on 2025/1/17.
//

import UIKit

/// 事例
class ViewController: UIViewController {
    
    lazy var manager: WAPipelineAlertManager = {
        let manager = WAPipelineAlertManager(vc: self)
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) { [weak self] in
            self?.addItem(count: 3)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.vc = self
        manager.alertFirstIfExist()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager.vc = nil
    }
    
    func addItem(count: Int) {
        for i in 0..<count {
            var config1 = NoteMsgViewController.MsgConfig(title: "通知\(i)", message: "细节-\(self)-\(i)", okText: "确认", cancelText: "取消")
            config1.isOpenVCByOk = true
            config1.okHandle = { [weak self] in
                let vc = ViewController()
                vc.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            let vc1 = NoteMsgViewController(config: config1)
            manager.addVC(item: vc1)
        }
    }
}


