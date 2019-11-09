//
//  CenteredItemLocator.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 07.10.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol CenteredItemLocatorDelegate: AnyObject {
    /// Useful to change the visible center of the CollectionView (for example when the part of the CollectionView is cover by other view)
    /// Default: `.zero`
    func centerOffset(for locator: CenteredItemLocator) -> CGPoint
    
    /// Asks the delegate if there are any cells that it should not consider while locating the centered item
    /// Useful when there are cells that are used as header or footer
    /// Default: `falue` ... means all cells would be considered
    func centeredItemLocator(_ locator: CenteredItemLocator, shouldExcludeItemAt indexPath: IndexPath) -> Bool
    
    /// Asks the delegate for confirmation before scrolling
    /// Useful if the view is not in a state that can scroll for any business reason
    /// Default: `true` ... always scroll
    func centeredItemLocator(_ locator: CenteredItemLocator, shouldScrollTo contentOffset: CGPoint) -> Bool
}

/// Locate the current centered item in the collectionView and scroll to it
public final class CenteredItemLocator {
    
    public weak var delegate: CenteredItemLocatorDelegate?
    
    public init() {
        
    }
    
    /// Locale the centered item in the given `bounds` for `collectionView`
    public func locateCenteredItem(in collectionView: UICollectionView, bounds: CGRect) -> IndexPath? {
        guard let layoutAttributesArray = collectionView.collectionViewLayout.layoutAttributesForElements(in: bounds) else {
            return nil
        }
        
        let adjustedCenter = collectionView.adjustedCenter
        let centerOffset = delegate?.centerOffset(for: self) ?? .zero
        let visibleCenter = CGPoint(
            x: adjustedCenter.x + centerOffset.x + bounds.minX,
            y: adjustedCenter.y + centerOffset.y + bounds.minY
        )

        return layoutAttributesArray.filter { layoutAttributes in
            !(delegate?.centeredItemLocator(self, shouldExcludeItemAt: layoutAttributes.indexPath) ?? false)
        }.map { layoutAttributes in
            (indexPath: layoutAttributes.indexPath, distanceToCenter: visibleCenter.distance(to: layoutAttributes.center))
        }.min {
            $0.distanceToCenter < $1.distanceToCenter
        }?.indexPath
    }
    
    /// Returns the offset that will display the `indexPath` centered in the `collectionView`
    public func contentOffset(for indexPath: IndexPath, toBeCenteredIn collectionView: UICollectionView) -> CGPoint? {
        guard let layoutAttributes = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        let adjustedCenter = collectionView.adjustedCenter
        let centerOffset = delegate?.centerOffset(for: self) ?? .zero
        let visibleCenter = CGPoint(
            x: adjustedCenter.x + centerOffset.x,
            y: adjustedCenter.y + centerOffset.y
        )
        
        let proposedXPosition = layoutAttributes.center.x - visibleCenter.x
        let proposedYPosition = layoutAttributes.center.y - visibleCenter.y
        let maximumXPosition = contentSize.width - collectionView.bounds.size.width + collectionView.adjustedContentInset.right
        let maximumYPosition = contentSize.height - collectionView.bounds.size.height + collectionView.adjustedContentInset.top
        let minimumXPosition = -collectionView.adjustedContentInset.left
        let minimumYPosition = -collectionView.adjustedContentInset.top
        let xPosition = min(max(proposedXPosition, minimumXPosition), maximumXPosition)
        let yPosition = min(max(proposedYPosition, minimumYPosition), maximumYPosition)
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    /// Scroll to the offset that will display the `indexPath` centered in the `collectionView`
    public func scrollToItem(at indexPath: IndexPath, toBeCenteredIn collectionView: UICollectionView) {
        guard let contentOffset = contentOffset(for: indexPath, toBeCenteredIn: collectionView) else {
            return
        }
        
        if delegate?.centeredItemLocator(self, shouldScrollTo: contentOffset) != false {
            collectionView.contentOffset = contentOffset
        }
    }
}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let xDistance = x - point.x
        let yDistance = y - point.y
        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }
}

private extension UIScrollView {
    var adjustedCenter: CGPoint {
        CGPoint(
            x: (bounds.size.width + adjustedContentInset.right - adjustedContentInset.left) / 2,
            y: (bounds.size.height + adjustedContentInset.top - adjustedContentInset.bottom) / 2
        )
    }
}
