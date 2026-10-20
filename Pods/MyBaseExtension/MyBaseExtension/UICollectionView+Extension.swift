//
//  UICollectionView+Extension.swift
//  MyBaseExtension
//
//  Created by ios on 2024/11/30.
//

import UIKit

public extension UICollectionView {
    
    func mRegister<T : UICollectionViewCell>(_ cellType: T.Type) {
        if Bundle.main.path(forResource: String(describing: cellType), ofType: "nib")?.first != nil {
            register(.init(nibName: String(describing: cellType), bundle: nil), forCellWithReuseIdentifier: NSStringFromClass(cellType))
        } else {
            register(cellType, forCellWithReuseIdentifier: NSStringFromClass(cellType))
        }
    }
    
    func mDequeueReusableCell<T : UICollectionViewCell>(_ cellType: T.Type, indexPath: IndexPath) -> T {
        if let cell = dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cellType), for: indexPath) as? T {
            return cell
        } else {
            fatalError("没有注册\(cellType)")
        }
    }
}
