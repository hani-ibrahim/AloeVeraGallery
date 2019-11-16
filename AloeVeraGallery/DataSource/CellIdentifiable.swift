//
//  CellIdentifiable.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol CellIdentifiable {
    static var identifier: String { get }
}

extension CellIdentifiable {
    public static var identifier: String {
        String(describing: self)
    }
}

extension UICollectionViewCell: CellIdentifiable {}
