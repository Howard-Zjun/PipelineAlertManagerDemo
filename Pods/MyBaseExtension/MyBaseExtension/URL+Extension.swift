//
//  URL+Extension.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/8/26.
//

import UIKit

public extension URL {
    
    /// 兼容不同版本添加文件夹路径
    func mAppendingDirectory(path: String) -> URL {
        if #available(iOS 16.0, *) {
            return appending(path: path, directoryHint: .isDirectory)
        } else {
            return appendingPathComponent(path, isDirectory: true)
        }
    }
    
    /// 移除文件夹下的文件
    @discardableResult
    func mRemoveDirItem() -> Bool {
        do {
            // skipsSubdirectoryDescendants 不遍历子文件夹
            // skipsPackageDescendants 不遍历包
            // skipsHiddenFiles 不遍历隐藏文件
            let urlArr = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsPackageDescendants, .skipsSubdirectoryDescendants])
            for url in urlArr {
                var isDirectory = ObjCBool(false)
                _ = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
                
                if isDirectory.boolValue {
                    url.mRemoveDirItem()
                    try? FileManager.default.removeItem(at: url)
                } else {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        } catch {
            print("\(#function) error: \(error)")
            return false
        }
        
        return true
    }
}
