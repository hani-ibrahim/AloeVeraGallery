//
//  PagedCollectionView.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Simple UIView with embded CollectionView that support paging scrolling with spaces and adjust rotation
/// ⚠️ You must call `collectionViewLayout.collectionViewSizeWillChange()` before the rotation start ... call it from `UIViewController.viewWillTransition` function
public class PagedCollectionView: UIView {
    
    public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    
    /// Set the space between pages horizontally or vertically
    public var pageSpacing: CGFloat = 0 {
        didSet {
            configure()
        }
    }
    
    public let collectionViewLayout = PagedCollectionViewFlowLayout()
    
    private var rightConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// Scroll the collection view to the given index
    public func scrollToItem(at indexPath: IndexPath) {
        collectionViewLayout.centeredItemLocator.scrollToItem(at: indexPath, toBeCenteredIn: collectionView)
    }
    
    /// Readjust the collectionView to support paging properly
    /// You might need to call this function in case you changed some properties like `scrollDirection`
    public func configure() {
        if collectionViewLayout.scrollDirection == .horizontal {
            collectionView.contentInset.right = pageSpacing
            collectionView.contentInset.bottom = 0
            collectionView.scrollIndicatorInsets.right = pageSpacing
            collectionView.scrollIndicatorInsets.bottom = 0
            rightConstraint?.constant = pageSpacing
            bottomConstraint?.constant = 0
        } else {
            collectionView.contentInset.right = 0
            collectionView.contentInset.bottom = pageSpacing
            rightConstraint?.constant = 0
            bottomConstraint?.constant = pageSpacing
            collectionView.scrollIndicatorInsets.right = 0
            collectionView.scrollIndicatorInsets.bottom = pageSpacing
        }
        collectionViewLayout.pageSpacing = pageSpacing
    }
    
    public override func layoutSubviews() {
        /// Fixing bug where some constraints mismatch might appear in the console during rotation
        collectionViewLayout.invalidateLayout()
        super.layoutSubviews()
    }
}

private extension PagedCollectionView {
    func setup() {
        addSubview(collectionView)
        translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = backgroundColor
        
        rightConstraint = collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate([
            rightConstraint,
            bottomConstraint,
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor)
        ])
        
        configure()
    }
}
