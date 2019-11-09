//
//  GalleryViewController.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraPagedCollectionView
import UIKit

open class GalleryViewController: UIViewController {
    
    @IBOutlet public private(set) var collectionView: UICollectionView!
    @IBOutlet public private(set) var collectionViewLayout: PagedCollectionViewFlowLayout!
    @IBOutlet public private(set) var closeButton: UIButton!
    @IBOutlet public private(set) var pageControl: UIPageControl!
    
    @IBOutlet private var rightConstraint: NSLayoutConstraint!
    
    private let dataSource: CollectionViewDataSource
    private let pageSpacing: CGFloat
    private let startIndex: Int?
    
    public init(sections: [SectionConfiguring], pageSpacing: CGFloat, startIndex: Int?) {
        self.dataSource = CollectionViewDataSource(sections: sections)
        self.pageSpacing = pageSpacing
        self.startIndex = startIndex
        super.init(nibName: nil, bundle: Bundle(for: GalleryViewController.self))
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:) has not been implemented")
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.collectionViewSizeWillChange()
    }
    
    @IBAction private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

private extension GalleryViewController {
    func setupView() {
        setupCollectionView()
        setup(pageSpacing: pageSpacing)
    }
    
    func setupCollectionView() {
        collectionView.dataSource = dataSource
        dataSource.registerCells(in: collectionView)
    }
    
    func setup(pageSpacing: CGFloat) {
        collectionView.contentInset.right = pageSpacing
        collectionViewLayout.pageSpacing = pageSpacing
        rightConstraint.constant = pageSpacing
    }
}
