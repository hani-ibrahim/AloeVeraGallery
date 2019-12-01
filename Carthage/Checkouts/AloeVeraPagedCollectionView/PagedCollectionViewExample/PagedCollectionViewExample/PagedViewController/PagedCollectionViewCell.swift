//
//  PagedCollectionViewCell.swift
//  PagedCollectionViewExample
//
//  Created by Hani on 10.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraPagedCollectionView
import UIKit

struct PagedCellViewModel {
    let title: String
}

final class PagedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private(set) var titleLabel: UILabel!
    
}

extension PagedCollectionViewCell: CellConfigurable {
    func configure(with viewModel: PagedCellViewModel) {
        titleLabel.text = viewModel.title
    }
}
