//
//  SectionConfigurator.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 01.12.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// `UICollectionViewCell` can conform to this protocol to update with with a type safe `ViewModel`
public protocol CellConfigurable {
    associatedtype ViewModel
    func configure(with viewModel: ViewModel)
}

public protocol SectionConfiguring {
    var numberOfCells: Int { get }
    func registerCell(in collectionView: UICollectionView)
    func dequeueCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
}

/// Configurator for collection view setion, that has the view model and cell type
public final class SectionConfigurator<Cell: UICollectionViewCell & CellConfigurable, ViewModel> where Cell.ViewModel == ViewModel {
    private let cellSource: CellSource
    private var viewModels: [ViewModel]
    
    public init(cellSource: CellSource, viewModels: [ViewModel] = []) {
        self.cellSource = cellSource
        self.viewModels = viewModels
    }
    
    /// Update the cell at the given index with the given view model
    /// You have to update the collection view after that to reflect the change
    /// - Parameters:
    ///   - index: Index of the cell in the section to update
    ///   - viewModel: The new view model of the cell
    public func update(cellAt index: Int, with viewModel: ViewModel) {
        guard viewModels.count > index else {
            assertionFailure("SectionConfigurator: updating cell at index: \(index) that doesn't exists")
            return
        }
        viewModels[index] = viewModel
    }
    
    /// Update all the cells in the collection view with the new view models
    /// You have to update the collection view after that to reflect the change
    /// - Parameter viewModels: The new view models of the section
    public func update(with viewModels: [ViewModel]) {
        self.viewModels = viewModels
    }
}

extension SectionConfigurator {
    /// Cell source to determine how to register it
    public enum CellSource {
        case storyboard /// No registration required
        case xib
        case code
    }
}

extension SectionConfigurator: SectionConfiguring {
    /// Total number of the cells in the section
    public var numberOfCells: Int {
        viewModels.count
    }
    
    /// Helper function to register the cell in the given `collectionView`
    /// - Parameter collectionView: The collection view to register the cells in
    public func registerCell(in collectionView: UICollectionView) {
        switch cellSource {
        case .storyboard:
            print("SectionConfigurator: skipping registering cell from storyboard as it is already registered")
        case .xib:
            collectionView.register(UINib(nibName: Cell.cellIdentifier, bundle: Bundle(for: Cell.self)), forCellWithReuseIdentifier: Cell.cellIdentifier)
        case .code:
            collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.cellIdentifier)
        }
    }
    
    /// Helper function to dequeue a cell for a collection view
    /// - Parameters:
    ///   - collectionView: The collection view to dequeue for
    ///   - indexPath: The index path to dequeue at
    public func dequeueCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.cellIdentifier, for: indexPath) as! Cell
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
}

extension CellConfigurable where Self: UICollectionViewCell {
    /// Alias to create a section for any `UICollectionViewCell` that conform to `CellConfigurable`
    public typealias Section = SectionConfigurator<Self, ViewModel>
}
