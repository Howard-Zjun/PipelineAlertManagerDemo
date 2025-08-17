//
//  PiplineItemViewController.swift
//  MYPipelineAlertManager
//
//  Created by ios on 2025/1/17.
//

import UIKit

protocol PiplineItemScheduleInformDelegate: NSObjectProtocol {
    
    func end(isOpenedVC: Bool)
}

class PiplineItemViewController: UIViewController {

    // 紧急程度，决定弹出顺序
    enum UrgencyDegree {
        case immediately // 立刻，下一个要弹出的位置
        case beforeNormal // 在普通之前
        case normal // 普通
        case last // 放在最后
    }
    
    weak var scheduleDelegate: PiplineItemScheduleInformDelegate?
    
    var isAlerting: Bool = false
    
    // 紧急程度
    var urgencyDegree: UrgencyDegree = .normal
    
    func dismiss(animated flag: Bool, isOpenedVC: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        scheduleDelegate?.end(isOpenedVC: isOpenedVC)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        scheduleDelegate?.end(isOpenedVC: false)
    }
}
