//
//  Int+Extension.swift
//  MyBaseExtension
//
//  Created by ios on 2025/4/26.
//

import UIKit

extension Int {
    
    // 转换中文简体描述
    func zn_cnFormat() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = .init(identifier: "zh_CN")
        numberFormatter.numberStyle = .spellOut
        return numberFormatter.string(from: .init(value: self))
    }
}
