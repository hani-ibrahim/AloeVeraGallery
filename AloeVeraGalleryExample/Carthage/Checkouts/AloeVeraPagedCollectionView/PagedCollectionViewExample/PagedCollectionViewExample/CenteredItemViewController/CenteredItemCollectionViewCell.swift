//
//  CenteredItemCollectionViewCell.swift
//  PagedCollectionViewExample
//
//  Created by Hani on 05.10.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraPagedCollectionView
import UIKit

struct CenteredItemCellViewModel {
    let title: String
    let backgroundColor: UIColor
}

final class CenteredItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private(set) var titleLabel: UILabel!
    
}

extension CenteredItemCollectionViewCell: CellConfigurable {
    func configure(with viewModel: CenteredItemCellViewModel) {
        titleLabel.text = viewModel.title
        backgroundColor = viewModel.backgroundColor
    }
}
