//
//  TimeResolver.swift
//  MyBaseExtension
//
//  Created by ios on 2025/4/26.
//

import UIKit

class TimeResolver: NSObject, Codable  {
    
    let date: Date
    
    var year: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date).intValue(defaultValue: 0)
    }
    
    /// 一年内第几个月
    var month: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        return dateFormatter.string(from: date).intValue(defaultValue: 0)
    }
    
    var weekOfYear: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.weekOfYear], from: date)
        return components.weekOfYear ?? 0
    }
    
    /// 一个月内第几天
    var dayOfMonth: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date).intValue(defaultValue: 0)
    }
    
    /// 一年内第几天
    var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 0
    }
    
    var hour: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        return dateFormatter.string(from: date).intValue(defaultValue: 0)
    }
    
    var minute: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        return dateFormatter.string(from: date).intValue(defaultValue: 0)
    }
    
    var second: Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ss"
        return dateFormatter.string(from: date).intValue(defaultValue: 0)
    }
    
    init(date: Date) {
        self.date = date
    }
    
    convenience init(timestamp: TimeInterval) {
        let date = Date(timeIntervalSince1970: timestamp)
        self.init(date: date)
    }
}
