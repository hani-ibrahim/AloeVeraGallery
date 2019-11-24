//
//  ImageCollectionViewCell.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public struct ImageCellViewModel {
    public let image: UIImage
    public let fillMode: GalleryFillMode
    
    public init(image: UIImage, fillMode: GalleryFillMode) {
        self.image = image
        self.fillMode = fillMode
    }
}

open class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    
}

extension ImageCollectionViewCell: CellConfigurable {
    open func configure(with viewModel: ImageCellViewModel) {
        imageView.image = viewModel.image
        imageView.contentMode = viewModel.fillMode.contentMode
    }
}

private extension GalleryFillMode {
    var contentMode: UIView.ContentMode {
        switch self {
        case .aspectFill:
            return .scaleAspectFill
        case .aspectFit:
            return .scaleAspectFit
        }
    }
}
