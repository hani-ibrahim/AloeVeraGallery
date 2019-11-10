//
//  CenteredItemCollectionViewFlowLayout.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 02.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Locate the current centered item in the collectionView during rotation and scroll to it
/// ⚠️ You must call `collectionViewSizeWillChange()` before the rotation start ... call it from `UIViewController.viewWillTransition` function
open class CenteredItemCollectionViewFlowLayout: UICollectionViewFlowLayout, CenteredItemLocating {
    
    open weak var centeredItemLocatingDelegate: CenteredItemLocatingDelegate?
    open private(set) var lastLocatedCenteredItemIndexPath: IndexPath? = nil
    
    open override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        
        guard let collectionView = collectionView, let indexPath = lastLocatedCenteredItemIndexPath, let layoutAttributes = layoutAttributesForItem(at: indexPath) else {
            return
        }
        
        let offset = contentOffset(
            forItemAtPosition: layoutAttributes.center,
            toBeCenteredIn: collectionView.bounds.size,
            near: collectionView.adjustedCenter,
            within: collectionView.adjustedContentInset,
            contentSize: collectionViewContentSize
        )
        scrollToItem(in: collectionView, to: offset)
    }
    
    /// ⚠️ Must be called before the rotation start
    open func collectionViewSizeWillChange() {
        guard let collectionView = collectionView, let layoutAttributesArray = layoutAttributesForElements(in: collectionView.bounds) else {
            return
        }
        
        let adjustedCenter = collectionView.adjustedCenter
        let contentVisibleCenter = CGPoint(
            x: adjustedCenter.x + collectionView.bounds.minX,
            y: adjustedCenter.y + collectionView.bounds.minY
        )
        let items = layoutAttributesArray.map { ItemLocation(indexPath: $0.indexPath, center: $0.center) }
        lastLocatedCenteredItemIndexPath = locateCenteredItem(near: contentVisibleCenter, from: items)
    }
}

private extension UIScrollView {
    var adjustedCenter: CGPoint {
        CGPoint(
            x: (bounds.size.width + adjustedContentInset.left - adjustedContentInset.right) / 2,
            y: (bounds.size.height + adjustedContentInset.top - adjustedContentInset.bottom) / 2
        )
    }
}
