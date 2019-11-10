//
//  UICollectionView+dequeue.swift
//  PagedCollectionViewExample
//
//  Created by Hani on 05.10.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

extension NSObject {
    static var identifier: String {
        String(describing: self)
    }
}

extension UICollectionView {
    func dequeueCell<T: UICollectionViewCell>(ofType type: T.Type, at indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
    
    func registerCell<T: UICollectionViewCell>(ofType type: T.Type) {
        register(UINib(nibName: T.identifier, bundle: Bundle(for: T.self)), forCellWithReuseIdentifier: T.identifier)
    }
}
