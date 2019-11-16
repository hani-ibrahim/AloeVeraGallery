//
//  CenteredItemLocating.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 10.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol CenteredItemLocatingDelegate: AnyObject {
    /// Useful to change the visible center of the ScrollView (for example when the part of the ScrollView is cover by other views)
    /// Default: `.zero`
    func centerOffset(for locator: CenteredItemLocating) -> CGPoint
    
    /// Asks the delegate if there are any cells that it should not consider while locating the centered item
    /// Useful when there are cells that are used as header or footer
    /// Default: `falue` ... means all cells would be considered
    func centeredItemLocator(_ locator: CenteredItemLocating, shouldExcludeItemAt indexPath: IndexPath) -> Bool
    
    /// Asks the delegate for confirmation before scrolling
    /// Useful if the view is not in a state that can scroll for any business reason
    /// Default: `true` ... always scroll
    func centeredItemLocator(_ locator: CenteredItemLocating, shouldScrollTo contentOffset: CGPoint) -> Bool
}

public typealias ItemLocation = (indexPath: IndexPath, center: CGPoint)

public protocol CenteredItemLocating {
    var centeredItemLocatingDelegate: CenteredItemLocatingDelegate? { get set }
}

extension CenteredItemLocating {
    /// Locate the centered item in the given bounds
    /// - Parameters:
    ///   - contentVisibleCenter: The point in the `contentSize` to find the nearest item to it ... normally would be `CGPoint(x: bounds.midX, y: bounds.midY)`
    ///   - items: All the items in the scroll view to search among them
    public func locateCenteredItem(near contentVisibleCenter: CGPoint, from items: [ItemLocation]) -> IndexPath? {
        let centerOffset = centeredItemLocatingDelegate?.centerOffset(for: self) ?? .zero
        let visibleCenter = CGPoint(
            x: centerOffset.x + contentVisibleCenter.x,
            y: centerOffset.y + contentVisibleCenter.y
        )
        return items.filter { item in
            !(centeredItemLocatingDelegate?.centeredItemLocator(self, shouldExcludeItemAt: item.indexPath) ?? false)
        }.map { item in
            (indexPath: item.indexPath, distanceToCenter: visibleCenter.distance(to: item.center))
        }.min {
            $0.distanceToCenter < $1.distanceToCenter
        }?.indexPath
    }
    
    /// The requested content offset to center the item at the given position
    /// - Parameters:
    ///   - itemCenter: The center of the item to scroll to in the scroll view
    ///   - size: The size of the scroll view
    ///   - viewableAreaCenter: The visible center point in the scroll view relative to the frame ... normally would be `CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)`
    ///   - contentInset: The content inset of the scroll view
    ///   - contentSize: The content size of the scroll view
    public func contentOffset(forItemAtPosition itemCenter: CGPoint, toBeCenteredIn size: CGSize, near viewableAreaCenter: CGPoint, within contentInset: UIEdgeInsets, contentSize: CGSize) -> CGPoint {
        let centerOffset = centeredItemLocatingDelegate?.centerOffset(for: self) ?? .zero
        let visibleXCenter = centerOffset.x + viewableAreaCenter.x
        let visibleYCenter = centerOffset.y + viewableAreaCenter.y
        let estimatedXPosition = itemCenter.x - visibleXCenter
        let estimatedYPosition = itemCenter.y - visibleYCenter
        let maximumXPosition = contentSize.width - size.width + contentInset.right
        let maximumYPosition = contentSize.height - size.height + contentInset.bottom
        let minimumXPosition = -contentInset.left
        let minimumYPosition = -contentInset.top
        let xPosition = min(max(estimatedXPosition, minimumXPosition), maximumXPosition)
        let yPosition = min(max(estimatedYPosition, minimumYPosition), maximumYPosition)
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    public func scrollToItem(in scrollView: UIScrollView, to contentOffset: CGPoint, animated: Bool) {
        if centeredItemLocatingDelegate?.centeredItemLocator(self, shouldScrollTo: contentOffset) != false {
            scrollView.setContentOffset(contentOffset, animated: animated)
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
