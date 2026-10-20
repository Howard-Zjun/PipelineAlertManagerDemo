//
//  UIImageExtension.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/8/21.
//

import UIKit
import AVFoundation

public extension UIImage {
    
    func mExport(toDirURL: URL) -> URL? {
        // 如果不存在父文件夹，这创建
        if !FileManager.default.fileExists(atPath: toDirURL.path) {
            try? FileManager.default.createDirectory(at: toDirURL, withIntermediateDirectories: true)
        }
        
        let prefixfileName = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let toURL = toDirURL.appendingPathComponent(prefixfileName)
        do {
            if let jpegData = jpegData(compressionQuality: 1.0) {
                let ret = toURL.appendingPathExtension("jpg")
                try jpegData.write(to: ret, options: .atomic)
                return ret
            } else if let pngData = pngData() {
                let ret = toURL.appendingPathExtension("png")
                try pngData.write(to: ret, options: .atomic)
                return ret
            }
        } catch {
            print("\(NSStringFromClass(Self.self)) \(#function) error: \(error)")
        }
        
        return nil
    }
    
    /// 缩略图
    static func mVideoThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 0.0, preferredTimescale: 600)
        do {
            let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("Error generating thumbnail: \(error)")
        }
        
        return nil
    }
}
