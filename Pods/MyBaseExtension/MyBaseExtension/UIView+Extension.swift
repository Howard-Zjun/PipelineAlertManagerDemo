//
//  UIViewExtension.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/18.
//

import UIKit

public extension UIView {
    
    var mMinX: CGFloat {
        get {
            frame.minX
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var mMinY: CGFloat {
        get {
            frame.minY
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var mMaxX: CGFloat {
        get {
            frame.maxX
        }
        set {
            frame.origin.x = newValue - mWidth
        }
    }
    
    var mMaxY: CGFloat {
        get {
            frame.maxY
        }
        set {
            frame.origin.y = newValue - mHeight
        }
    }
    
    var mWidth: CGFloat {
        get {
            frame.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    var mHeight: CGFloat {
        get {
            frame.height
        }
        set {
            frame.size.height = newValue
        }
    }
    
    @discardableResult
    // 添加两层波纹动画
    func rippleAnimation(strokeColor: UIColor = .init(hex: 0x3F87FF), beginTime: CFTimeInterval = 0) -> [CAShapeLayer]? {
        guard let superView = self.superview else { return nil }
        
        let beginPath = UIBezierPath(arcCenter: center, radius: min(mHeight, mWidth) * 0.5 - 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        let endPath = UIBezierPath(arcCenter: center, radius: min(mHeight, mWidth) * 0.8, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.lineWidth = 2
        shapeLayer1.path = beginPath.cgPath
        shapeLayer1.fillColor = UIColor.clear.cgColor
        shapeLayer1.strokeColor = strokeColor.cgColor
        
        superView.layer.insertSublayer(shapeLayer1, at: 0)
        
        let after = 0.4
        
        let firstOpacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        firstOpacityAnimation.values = [NSNumber(value: 1), NSNumber(value: 0.4), NSNumber(value: 0)]
        firstOpacityAnimation.keyTimes = [NSNumber(value: 0), NSNumber(value: 1 - after), NSNumber(value: 1)]
        let firstPathAnimtion = CAKeyframeAnimation(keyPath: "path")
        firstPathAnimtion.values = [beginPath.cgPath, endPath.cgPath, endPath.cgPath]
        firstPathAnimtion.keyTimes = [NSNumber(value: 0), NSNumber(value: 1 - after), NSNumber(value: 1)]
        firstPathAnimtion.timingFunctions = [.init(name: .linear), .init(name: .easeOut), .init(name: .linear)]
        
        
        let group = CAAnimationGroup()
        group.animations = [firstOpacityAnimation, firstPathAnimtion]
        group.repeatCount = .greatestFiniteMagnitude
        group.duration = 1.5
        shapeLayer1.add(group, forKey: "twoLayerRippleAnimation1\(Date())")
        
        let shapeLayer2 = CAShapeLayer()
        shapeLayer2.lineWidth = 2
        shapeLayer2.path = beginPath.cgPath
        shapeLayer2.fillColor = UIColor.clear.cgColor
        shapeLayer2.strokeColor = strokeColor.cgColor
        
        superView.layer.insertSublayer(shapeLayer2, at: 0)
        
        let twoOpacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        twoOpacityAnimation.values = [NSNumber(value: 1), NSNumber(value: 1), NSNumber(value: 0.4)]
        twoOpacityAnimation.keyTimes = [NSNumber(value: 0), NSNumber(value: after), NSNumber(value: 1)]
        let twoPathAnimation = CAKeyframeAnimation(keyPath: "path")
        twoPathAnimation.values = [beginPath.cgPath, beginPath.cgPath, endPath.cgPath]
        twoPathAnimation.keyTimes = [NSNumber(value: 0), NSNumber(value: after), NSNumber(value: 1)]
        
        let group2 = CAAnimationGroup()
        group2.animations = [twoOpacityAnimation, twoPathAnimation]
        group2.repeatCount = .greatestFiniteMagnitude
        group2.duration = 1.5
        shapeLayer2.add(group2, forKey: "twoLayerRippleAnimation2\(Date())")
        
        return [shapeLayer1, shapeLayer2]
    }
}
