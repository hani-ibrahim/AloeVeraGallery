//
//  CellConfigurable.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol CellConfigurable {
    associatedtype ViewModel
    
    func configure(with viewModel: ViewModel)
}

extension CellConfigurable where Self: UICollectionViewCell {
    public typealias Section = SectionConfigurator<Self, ViewModel>
}
