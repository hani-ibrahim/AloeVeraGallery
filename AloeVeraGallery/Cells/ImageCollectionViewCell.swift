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
    
    public init(image: UIImage) {
        self.image = image
    }
}

open class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    
}

extension ImageCollectionViewCell: CellConfigurable {
    public func configure(with viewModel: ImageCellViewModel) {
        imageView.image = viewModel.image
    }
}
