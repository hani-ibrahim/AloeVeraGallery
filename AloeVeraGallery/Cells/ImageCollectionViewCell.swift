//
//  ImageCollectionViewCell.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public enum ImageCellContentMode {
    case aspectFill
    case aspectFit
}

public struct ImageCellViewModel {
    public let image: UIImage
    public let contentMode: ImageCellContentMode
    
    public init(image: UIImage, contentMode: ImageCellContentMode) {
        self.image = image
        self.contentMode = contentMode
    }
}

open class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    
    public var cropMode: GallerySourceCropMode {
        if let imageSize = imageView.image?.size, imageView.contentMode == .scaleAspectFill {
            let imageViewSize = imageView.frame.size
            print("imageViewSize: \(imageViewSize), imageSize: \(imageSize)")
            return imageViewSize.width / imageViewSize.height > imageSize.width / imageSize.height ? .verticalCrop : .horizontalCrop
        } else {
            return .none
        }
    }
}

extension ImageCollectionViewCell: CellConfigurable {
    open func configure(with viewModel: ImageCellViewModel) {
        imageView.image = viewModel.image
        imageView.contentMode = viewModel.contentMode.imageContentMode
    }
}

private extension ImageCellContentMode {
    var imageContentMode: UIView.ContentMode {
        switch self {
        case .aspectFill:
            return .scaleAspectFill
        case .aspectFit:
            return .scaleAspectFit
        }
    }
}
