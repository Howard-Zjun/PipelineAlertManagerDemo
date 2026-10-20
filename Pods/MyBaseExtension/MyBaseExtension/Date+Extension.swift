//
//  Date+Extension.swift
//  MyBaseExtension
//
//  Created by ios on 2025/1/18.
//

import UIKit

public extension Date {
    
    /// 第几年
    var year: Int {
        Calendar.current.dateComponents([.year], from: self).year ?? 0
    }
    
    /// 一年内第几个月
    var month: Int {
        Calendar.current.dateComponents([.month], from: self).month ?? 0
    }
    
    /// 一个月内第几周
    var weekOfMonth: Int {
        Calendar.current.dateComponents([.weekOfMonth], from: self).weekOfMonth ?? 0
    }
    
    /// 一年内第几周
    var weekOfYear: Int {
        Calendar.current.dateComponents([.weekOfYear], from: self).weekOfYear ?? 0
    }
    
    /// 一个月内第几天
    var dayOfMonth: Int {
        Calendar.current.dateComponents([.day], from: self).day ?? 0
    }
    
    /// 一年内第几天
    var dayOfYear: Int {
        Calendar.current.ordinality(of: .day, in: .year, for: self) ?? 0
    }
    
    /// 一天内第几天
    var hourOfDay: Int {
        Calendar.current.dateComponents([.hour], from: self).hour ?? 0
    }
    
    /// 一个月内第几小时
    var hourOfMonth: Int {
        Calendar.current.ordinality(of: .hour, in: .month, for: self) ?? 0
    }
    
    /// 一年内第几小时
    var hourOfYear: Int {
        Calendar.current.ordinality(of: .hour, in: .year, for: self) ?? 0
    }
    
    /// 一天内多少分钟
    var minuteOfDay: Int {
        Calendar.current.dateComponents([.minute], from: self).minute ?? 0
    }
    
    /// 一个月多少分钟
    var minuteOfMonth: Int {
        Calendar.current.ordinality(of: .minute, in: .month, for: self) ?? 0
    }
    
    /// 一年内多少分钟
    var minuteOfYear: Int {
        Calendar.current.ordinality(of: .minute, in: .year, for: self) ?? 0
    }
    
    /// 一天内多少秒
    var secondOfDay: Int {
        Calendar.current.dateComponents([.second], from: self).second ?? 0
    }
    
    /// 一个月内多少秒
    var secondOfMonth: Int {
        Calendar.current.ordinality(of: .second, in: .month, for: self) ?? 0
    }
    
    /// 一年内多少秒
    var secondOfYear: Int {
        Calendar.current.ordinality(of: .second, in: .year, for: self) ?? 0
    }
}
