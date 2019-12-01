//
//  DataSource.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 01.12.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Utility class for `UICollectionView` dataSource
public final class DataSource: NSObject {
    
    private let sections: [SectionConfiguring]
    
    public init(sections: [SectionConfiguring]) {
        self.sections = sections
    }
    
    /// Register cells in the given collection view
    /// You have to call this function to register your cells
    /// - Parameter collectionView: The collection view to register the cells in
    public func registerCells(in collectionView: UICollectionView) {
        sections.forEach { $0.registerCell(in: collectionView) }
    }
}

extension DataSource: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].numberOfCells
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        sections[indexPath.section].dequeueCell(for: collectionView, at: indexPath)
    }
}

extension DataSource {
    /// Returns the total number of cells in all sections
    /// Helpful for page indicators
    public var totalNumberOfItems: Int {
        sections.reduce(into: 0) { result, section in
            result += section.numberOfCells
        }
    }
    
    /// Getting the absolute index for the given `IndexPath`
    ///  Example:   Having `UICollectionView` with `2` sections, each section has `3` celll
    ///          Then `indexPath = IndexPath(item: 1, section: 1)` gives absolute index of `4`
    /// - Parameter indexPath: The `IndexPath` to find the absolute index for
    public func absoluteIndex(forItemAt indexPath: IndexPath) -> Int {
        (0..<sections.count).reduce(into: 0) { result, sectionIndex in
            if sectionIndex < indexPath.section {
                result += sections[sectionIndex].numberOfCells
            } else if sectionIndex == indexPath.section {
                result += indexPath.item
            }
        }
    }
}
