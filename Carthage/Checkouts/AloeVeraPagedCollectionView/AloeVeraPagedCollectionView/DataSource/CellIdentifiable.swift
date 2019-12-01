//
//  CellIdentifiable.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 01.12.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol CellIdentifiable {
    static var cellIdentifier: String { get }
}

extension CellIdentifiable {
    public static var cellIdentifier: String {
        String(describing: self)
    }
}

extension UICollectionViewCell: CellIdentifiable {}
