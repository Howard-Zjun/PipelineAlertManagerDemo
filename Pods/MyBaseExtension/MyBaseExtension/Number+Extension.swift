//
//  Number+Extension.swift
//  MyBaseExtension
//
//  Created by ios on 2024/11/29.
//

import UIKit

public extension NSNumber {
    
    func mStringFormat(locale: Locale) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = locale
        numberFormatter.numberStyle = .spellOut
        return numberFormatter.string(from: self)
    }
    
    /// 中文文字格式化
    var mZh_cnFormat: String? {
        mStringFormat(locale: .init(identifier: "zh_CN"))
    }
    
    /// 英文文字格式化
    var mEn_usFormat: String? {
        mStringFormat(locale: .init(identifier: "en_us"))
    }
    
    
}
