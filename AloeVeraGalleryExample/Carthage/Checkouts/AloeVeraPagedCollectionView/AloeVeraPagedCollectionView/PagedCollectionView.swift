//
//  PagedCollectionView.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Simple UIView with embded CollectionView that support paging scrolling with spaces and adjust rotation
/// This class is not a mandatory to use this library ... you can also use `PagedCollectionViewLayout` directly
public class PagedCollectionView: UIView {
    
    public lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    public let collectionViewLayout = PagedCollectionViewLayout()
    
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// Readjust the collectionView to support paging properly
    /// You might need to call this function in case you changed some properties in `collectionViewLayout`
    public func configure() {
        let pageSpacing = collectionViewLayout.pageSpacing
        let contentInset: UIEdgeInsets
        if collectionViewLayout.scrollDirection == .horizontal {
            contentInset = UIEdgeInsets(top: 0, left: pageSpacing / 2, bottom: 0, right: pageSpacing / 2)
        } else {
            contentInset = UIEdgeInsets(top: pageSpacing / 2, left: 0, bottom: pageSpacing / 2, right: 0)
        }

        collectionViewLayout.collectionViewInset = contentInset
        collectionView.scrollIndicatorInsets = contentInset
        topConstraint.constant = contentInset.top
        bottomConstraint.constant = contentInset.bottom
        rightConstraint.constant = contentInset.right
        leftConstraint.constant = contentInset.left
    }
}

private extension PagedCollectionView {
    func setup() {
        addSubview(collectionView)
        translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = backgroundColor
        
        topConstraint = topAnchor.constraint(equalTo: collectionView.topAnchor)
        bottomConstraint = collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        rightConstraint = collectionView.rightAnchor.constraint(equalTo: rightAnchor)
        leftConstraint = leftAnchor.constraint(equalTo: collectionView.leftAnchor)
        
        NSLayoutConstraint.activate([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        
        configure()
    }
}
