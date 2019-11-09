//
//  SectionConfigurator.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol SectionConfiguring {
    var numberOfCells: Int { get }
    func registerCell(for collectionView: UICollectionView)
    func dequeueCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
}

public struct SectionConfigurator<Cell: UICollectionViewCell & CellConfigurable, ViewModel> where Cell.ViewModel == ViewModel {
    
    public enum CellSource {
        case xib
        case code
    }
    
    private let viewModels: [ViewModel]
    private let cellSource: CellSource
    
    public init(viewModels: [ViewModel], cellSource: CellSource) {
        self.viewModels = viewModels
        self.cellSource = cellSource
    }
}

extension SectionConfigurator: SectionConfiguring {
    public var numberOfCells: Int {
        viewModels.count
    }
    
    public func registerCell(for collectionView: UICollectionView) {
        switch cellSource {
        case .xib:
            collectionView.register(UINib(nibName: Cell.identifier, bundle: Bundle(for: Cell.self)), forCellWithReuseIdentifier: Cell.identifier)
        case .code:
            collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        }
    }
    
    public func dequeueCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as! Cell
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
}
