//
//  GalleryFillMode.swift
//  AloeVeraGallery
//
//  Created by Hani on 24.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Describe how the content is displayed inside the cell
/// Helpful for transition animation
public enum GalleryFillMode {
    case aspectFill
    case aspectFit
}

extension GalleryFillMode {
    public var contentMode: UIView.ContentMode {
        switch self {
        case .aspectFill:
            return .scaleAspectFill
        case .aspectFit:
            return .scaleAspectFit
        }
    }
}
