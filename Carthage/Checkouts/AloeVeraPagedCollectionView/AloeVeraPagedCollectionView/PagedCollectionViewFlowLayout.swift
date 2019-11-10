//
//  PagedCollectionViewFlowLayout.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 02.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Changes the cells sizes during rotation to fill the whole collection view
/// ⚠️ You must call `collectionViewSizeWillChange()` before the rotation start ... call it from `UIViewController.viewWillTransition` function
open class PagedCollectionViewFlowLayout: CenteredItemCollectionViewFlowLayout {
    
    /// The spacing between each page which is only visible during scrolling
    public var pageSpacing: CGFloat = 0 {
        didSet {
            shouldConfigurePage = true
            invalidateLayout()
        }
    }
    
    private var shouldConfigurePage = true
    
    open override func prepare() {
        guard let collectionView = collectionView else {
            super.prepare()
            return
        }
        
        if shouldConfigurePage {
            minimumInteritemSpacing = 0
            minimumLineSpacing = pageSpacing
            sectionInset = .zero
            collectionView.contentInsetAdjustmentBehavior = .never
            shouldConfigurePage = false
        }
        
        let newItemSize = collectionView.bounds.inset(by: collectionView.contentInset).size
        let shouldInvalidate = itemSize != newItemSize
        itemSize = newItemSize
        
        super.prepare()
        
        /// Fixing bug in UICollectionViewFlowLayout where the `itemSize` is not applied except with `invalidateLayout` is called after `prepare`
        if shouldInvalidate {
            invalidateLayout()
        }
    }
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let collectionView = collectionView, let rotatingIndexPath = lastLocatedCenteredItemIndexPath, itemIndexPath != rotatingIndexPath else {
            return nil
        }
        
        // Sometimes there are overlapping cells appears during rotation
        // So hiding the unneeded cells by moving them far away
        let attributes = layoutAttributesForItem(at: itemIndexPath)?.copy() as? UICollectionViewLayoutAttributes
        if itemIndexPath < rotatingIndexPath {
            attributes?.frame.origin.x -= collectionView.bounds.width
            attributes?.frame.origin.y -= collectionView.bounds.height
        } else {
            attributes?.frame.origin.x += collectionView.bounds.width
            attributes?.frame.origin.y += collectionView.bounds.height
        }
        return attributes
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        layoutAttributesForItem(at: itemIndexPath)
    }
}
