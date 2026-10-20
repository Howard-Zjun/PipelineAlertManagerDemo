//
//  MyDateUnit.swift
//  MyBaseExtension
//
//  Created by ios on 2024/10/12.
//

import UIKit

class MyDateUnit: NSObject {

    /// 毫秒
    static var currentMilliSecond: Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
    
    /// 秒
    static var currentTimeSecond: Int {
        Int(Date().timeIntervalSince1970)
    }
    
    static func toSeconds(minutes: Int) -> Int {
        minutes * 60
    }
    
    static func toMinutes(hours: Int) -> Int {
        hours * 60
    }
    
    /// 毫秒格式化
    static func parseTime(milliSecond: Int) -> String {
        let second = milliSecond / 1000
        return parseTime(second: second)
    }
    
    /// 秒格式化
    static func parseTime(second: Int) -> String {
        let hour = second / 3600
        let min = second % 3600 / 60
        let sec = second % 60
        
        var ret = ""
        if hour > 0 {
            ret += String(format: "%02d:", hour)
        }
        if min > 0 {
            ret += String(format: "%02d:", min)
        }
        ret += String(format: "%02d", sec)
        return ret
    }
}
