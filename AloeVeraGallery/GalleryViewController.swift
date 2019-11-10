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
    
    @IBOutlet public private(set) var pagedCollectionView: PagedCollectionView!
    @IBOutlet public private(set) var closeButton: UIButton!
    @IBOutlet public private(set) var pageControl: UIPageControl!
    
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
        fatalError("Please use init(sections:pageSpacing:startIndex) function to initialize GalleryViewController")
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Please use init(sections:pageSpacing:startIndex) function to initialize GalleryViewController")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        pagedCollectionView.collectionViewLayout.collectionViewSizeWillChange()
    }
    
    @IBAction private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

private extension GalleryViewController {
    func setupView() {
        pagedCollectionView.pageSpacing = pageSpacing
        pagedCollectionView.collectionView.dataSource = dataSource
        pagedCollectionView.collectionViewLayout.scrollDirection = .horizontal
        dataSource.registerCells(in: pagedCollectionView.collectionView)
        pagedCollectionView.configure()
    }
}
