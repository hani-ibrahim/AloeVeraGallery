//
//  PagedCollectionViewFlowLayout.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 02.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Changes the cells sizes during rotation to fill the whole collection view
/// ⚠️ You must call `willRotate()` before the rotation start ... call it from `UIViewController.viewWillTransition` function
open class PagedCollectionViewFlowLayout: CenteredItemCollectionViewFlowLayout {
    
    /// The insets for each page individual
    public var pageInsets: UIEdgeInsets = .zero
    
    /// The spacing between each page that is only visible during scrolling
    public var pageSpacing: CGFloat = .zero
    
    /// When set to `false` -> the cells will fill the whole available space
    public var shouldRespectAdjustedContentInset = true
    
    open override func prepare() {
        if let collectionView = collectionView {
            minimumInteritemSpacing = 0
            sectionInset = .zero
            collectionView.decelerationRate = .fast
            collectionView.contentInset = pageInsets
            
            if scrollDirection == .horizontal {
                minimumLineSpacing = pageInsets.horizontalEdges + pageSpacing
            } else {
                minimumLineSpacing = pageInsets.verticalEdges + pageSpacing
            }
            
            let contentInsets: UIEdgeInsets
            if shouldRespectAdjustedContentInset {
                contentInsets = collectionView.adjustedContentInset
                collectionView.contentInsetAdjustmentBehavior = .automatic
            } else {
                contentInsets = collectionView.contentInset
                collectionView.contentInsetAdjustmentBehavior = .never
            }
            
            itemSize = CGSize(
                width: collectionView.bounds.size.width - contentInsets.horizontalEdges,
                height: collectionView.bounds.size.height - contentInsets.verticalEdges
            )
        }
        super.prepare()
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }
        
        var origin = collectionView.bounds.origin
        let speedThreshold: CGFloat = 0.5
        if scrollDirection == .horizontal {
            if velocity.x > speedThreshold {
                origin.x += collectionView.bounds.width
            } else if velocity.x < -speedThreshold {
                origin.x -= collectionView.bounds.width
            }
        } else {
            if velocity.y > speedThreshold {
                origin.y += collectionView.bounds.height
            } else if velocity.y < -speedThreshold {
                origin.y -= collectionView.bounds.height
            }
        }
        
        let bounds = CGRect(origin: proposedContentOffset, size: collectionView.bounds.size)
        guard let indexPath = centeredItemLocator.locateCenteredItem(in: collectionView, bounds: bounds),
            let contectOffset = centeredItemLocator.contentOffset(for: indexPath, toBeCenteredIn: collectionView) else {
                return proposedContentOffset
        }
        return contectOffset
    }
}

private extension UIEdgeInsets {
    var horizontalEdges: CGFloat {
        left + right
    }
    
    var verticalEdges: CGFloat {
        top + bottom
    }
}
