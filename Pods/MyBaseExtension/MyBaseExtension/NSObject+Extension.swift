//
//  NSObject+Extension.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/21.
//

import UIKit

public extension NSObject {
    
    /// 创建一个颜色图片
    func mCreateImage(color: UIColor, size: CGSize) -> UIImage {
        color.mRreateImage(size: size)
    }
    
    /// 绘制渐变图片
    func mCreateImage(colors: [UIColor], size: CGSize) -> UIImage {
        let cgColors = colors.map({ $0.cgColor })
        var locations: [CGFloat] = []
        for (index, _) in colors.enumerated() {
            locations.append(CGFloat(index) / CGFloat(colors.count - 1))
        }
        let gradient = CGGradient(colorsSpace: nil, colors: cgColors as CFArray, locations: locations)!
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let ret = renderer.image { context in
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: size.width, y: size.height)
            context.cgContext.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        }
        return ret
    }
}

public extension CALayer {
    
    func mCreateImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let ret = renderer.image { [weak self] context in
            self?.render(in: context.cgContext)
        }
        return ret
    }
}

public extension NSObject {
    
    func mToSetting(title: String, message: String) {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let toSettingAction = UIAlertAction(title: "去设置", style: .default) { action in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        }
        vc.addAction(cancelAction)
        vc.addAction(toSettingAction)
        if let mKeyWindow {
            mKeyWindow.rootViewController?.present(vc, animated: true)
        }
    }
}

