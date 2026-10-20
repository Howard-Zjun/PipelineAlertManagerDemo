//
//  Tool.swift
//  BaseExtension
//
//  Created by Howard-Zjun on 2024/08/18.
//

import UIKit

public var mIsiPhoneXMore: Bool {
    var isMore:Bool = false
    if #available(iOS 11.0, *) {
        if let mKeyWindow {
            isMore = mKeyWindow.safeAreaInsets.bottom > 0.0
        } else {
            isMore = false
        }
    }
    return isMore
}

public var mKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }.first?.windows
        .filter { $0.isKeyWindow }.first
}

public var mHomeDirPath: String {
    NSHomeDirectory()
}

public var mHomeDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: mHomeDirPath)
    } else {
        return URL(fileURLWithPath: mHomeDirPath)
    }
}

public var mDocumentsDirPath: String {
    NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
}

public var mDocumentsDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: mDocumentsDirPath)
    } else {
        return URL(fileURLWithPath: mDocumentsDirPath)
    }
}

public var mCachesDirPath: String {
    NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
}

public var mCachesDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: mCachesDirPath)
    } else {
        return URL(fileURLWithPath: mCachesDirPath)
    }
}

public var mTmpDirPath: String {
    NSTemporaryDirectory()
}

public var mTmpDirAt: URL {
    if #available(iOS 16.0, *) {
        return URL(filePath: mTmpDirPath)
    } else {
        return URL(fileURLWithPath: mTmpDirPath)
    }
}

public var mAppVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}

public var mBuildVersion: String {
    Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
}

public var mDisplayName: String {
    Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
}

/// 文件复制
/// - Parameters:
///   - atPath: 源文件位置
///   - toDirPath: 要复制到的文件夹位置
///   - overwrite: 是否覆盖
///   - errorDes: 错误描述
/// - Returns: 文件复制是否成功
public func mCopyItem(atPath: String, toDirPath: String, overwrite: Bool, errorDes: inout Error) -> Bool {
    if !FileManager.default.fileExists(atPath: atPath) {
        return false
    }
    
    guard let atURL = URL(string: atPath) else {
        return false
    }
    
    let fileName = atURL.lastPathComponent
    
    guard let toDirPathURL = URL(string: toDirPath) else {
        return false
    }
    
    let toPath = toDirPathURL.appendingPathComponent(fileName).absoluteString
    
    return mCopyItem(atPath: atPath, toPath: toPath, overwrite: overwrite, errorDes: &errorDes)
}

/// 文件复制
/// - Parameters:
///   - atPath: 源文件位置
///   - toPath: 要复制到的文件位置（包含文件名）
///   - overwrite: 是否覆盖
///   - errorDes: 错误描述
/// - Returns: 文件复制是否成功
public func mCopyItem(atPath: String, toPath: String, overwrite: Bool, errorDes: inout Error) -> Bool {
    if !FileManager.default.fileExists(atPath: atPath) {
        return false
    }
    
    guard let toURL = URL(string: toPath) else {
        return false
    }
    
    do {
        let toURLDir = toURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: toURLDir.absoluteString) {
            try FileManager.default.createDirectory(at: toURLDir, withIntermediateDirectories: true)
        }
        
        if overwrite && FileManager.default.fileExists(atPath: toPath) {
            try FileManager.default.removeItem(atPath: toPath)
        }
        
        try FileManager.default.copyItem(atPath: atPath, toPath: toPath)
        return true
    } catch {
        errorDes = error
        print("Error \(error)")
    }
    
    return false
}



